const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

const db = admin.firestore();
const messaging = admin.messaging();

// Twilio setup (gunakan env vars)
const twilio = require('twilio');
const twilioClient = twilio(
  functions.config().twilio?.sid,
  functions.config().twilio?.token
);

/**
 * Trigger saat report baru dibuat (non-SOS).
 * Mencari responder sesuai kategori dan kirim FCM NEW_REPORT.
 */
exports.sendReportNotification = functions.firestore
  .document('reports/{reportId}')
  .onCreate(async (snap, context) => {
    const report = snap.data();
    const reportId = context.params.reportId;

    // Skip jika SOS (ditangani oleh sendSOS)
    if (report.type === 'SOS') {
      return null;
    }

    // Set status ke 'Belum ditanggapi' jika belum ada
    if (report.status !== 'Belum ditanggapi') {
      await snap.ref.update({ status: 'Belum ditanggapi' });
    }

    // Cari responder yang tersedia (status = 'Tersedia')
    const respondersSnapshot = await db
      .collection('responders')
      .where('status', '==', 'Tersedia')
      .get();

    if (respondersSnapshot.empty) {
      console.log('No available responders');
      return null;
    }

    // Kirim FCM ke semua responder tersedia
    const tokens = respondersSnapshot.docs
      .map((doc) => doc.data().fcmToken)
      .filter((token) => token != null);

    if (tokens.length === 0) {
      console.log('No FCM tokens found');
      return null;
    }

    const payload = {
      notification: {
        title: 'LAPORAN BARU',
        body: `${report.userName}: ${report.description.substring(0, 50)}...`,
      },
      data: {
        type: 'NEW_REPORT',
        reportId: reportId,
      },
    };

    try {
      await messaging.sendToDevice(tokens, payload);
      console.log(`Sent NEW_REPORT to ${tokens.length} responders`);
    } catch (error) {
      console.error('Error sending FCM:', error);
    }

    return null;
  });

/**
 * Callable function untuk mengirim SOS.
 * Mengirim SMS ke kontak darurat dan FCM SOS_ALERT ke responder.
 */
exports.sendSOS = functions.https.onCall(async (data, context) => {
  // Verifikasi auth
  if (!context.auth) {
    throw new functions.https.HttpsError(
      'unauthenticated',
      'User must be authenticated'
    );
  }

  const { reportId } = data;
  if (!reportId) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'reportId is required'
    );
  }

  // Baca report SOS
  const reportDoc = await db.collection('reports').doc(reportId).get();
  if (!reportDoc.exists) {
    throw new functions.https.HttpsError('not-found', 'Report not found');
  }

  const report = reportDoc.data();

  // Baca user untuk ambil kontak darurat
  const userDoc = await db.collection('users').doc(report.userId).get();
  if (!userDoc.exists) {
    throw new functions.https.HttpsError('not-found', 'User not found');
  }

  const user = userDoc.data();
  const contacts = user.contacts || [];

  // Kirim SMS ke setiap kontak darurat via Twilio
  const twilioFrom = functions.config().twilio?.from;
  if (twilioFrom && twilioClient) {
    const locationLink = report.lat && report.lng
      ? `https://www.google.com/maps/search/?api=1&query=${report.lat},${report.lng}`
      : 'Lokasi tidak tersedia';

    const smsBody = `DARURAT !! ${report.userName} BUTUH PERTOLONGAN ANDA\nLokasi: ${locationLink}`;

    for (const contact of contacts) {
      try {
        await twilioClient.messages.create({
          body: smsBody,
          from: twilioFrom,
          to: contact,
        });
        console.log(`SMS sent to ${contact}`);
      } catch (error) {
        console.error(`Failed to send SMS to ${contact}:`, error);
      }
    }
  }

  // Cari responder tersedia dan kirim FCM SOS_ALERT
  const respondersSnapshot = await db
    .collection('responders')
    .where('status', '==', 'Tersedia')
    .get();

  const tokens = respondersSnapshot.docs
    .map((doc) => doc.data().fcmToken)
    .filter((token) => token != null);

  if (tokens.length > 0) {
    const payload = {
      notification: {
        title: 'SOS ALERT',
        body: `${report.userName} BUTUH BANTUAN !!`,
      },
      data: {
        type: 'SOS_ALERT',
        reportId: reportId,
        userName: report.userName,
        lat: String(report.lat || ''),
        lng: String(report.lng || ''),
      },
    };

    try {
      await messaging.sendToDevice(tokens, payload);
      console.log(`Sent SOS_ALERT to ${tokens.length} responders`);
    } catch (error) {
      console.error('Error sending FCM:', error);
    }
  }

  // Update status ke SOS_SENT
  await reportDoc.ref.update({
    status: 'SOS_SENT',
    alertedAt: admin.firestore.FieldValue.serverTimestamp(),
  });

  return { ok: true };
});

/**
 * Callable function untuk responder acknowledge report.
 * Update report dengan responder info dan kirim FCM SOS_ACK ke reporter.
 */
exports.acknowledgeReport = functions.https.onCall(async (data, context) => {
  if (!context.auth) {
    throw new functions.https.HttpsError(
      'unauthenticated',
      'User must be authenticated'
    );
  }

  const { reportId, responderId, responderName, responseMessage } = data;
  if (!reportId || !responderId || !responderName) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'reportId, responderId, responderName are required'
    );
  }

  // Transaction untuk atomic update
  return db.runTransaction(async (transaction) => {
    const reportRef = db.collection('reports').doc(reportId);
    const reportDoc = await transaction.get(reportRef);

    if (!reportDoc.exists) {
      throw new functions.https.HttpsError('not-found', 'Report not found');
    }

    const report = reportDoc.data();

    // Cek apakah sudah di-assign
    if (report.responderId && report.status === 'Menanggapi') {
      throw new functions.https.HttpsError(
        'already-exists',
        'Report already acknowledged'
      );
    }

    // Update report
    transaction.update(reportRef, {
      status: 'Menanggapi',
      responderId: responderId,
      responderName: responderName,
      respondedAt: admin.firestore.FieldValue.serverTimestamp(),
      ...(responseMessage && { responseMessage: responseMessage }),
    });

    // Update responder status
    const responderRef = db.collection('responders').doc(responderId);
    const responderDoc = await transaction.get(responderRef);
    if (responderDoc.exists) {
      transaction.update(responderRef, {
        status: 'Menanggapi',
      });
    }

    // Kirim FCM SOS_ACK ke reporter
    const userDoc = await transaction.get(
      db.collection('users').doc(report.userId)
    );
    if (userDoc.exists) {
      const user = userDoc.data();
      // Note: FCM token untuk reporter bisa disimpan di users collection
      // atau di deviceTokens collection
      const reporterToken = user.fcmToken;
      if (reporterToken) {
        const payload = {
          notification: {
            title: 'Laporan Diterima',
            body: 'LAPORAN ANDA DITERIMA. RESPONDER MENUJU LOKASI',
          },
          data: {
            type: 'SOS_ACK',
            reportId: reportId,
            responderName: responderName,
            responderPhone: responderDoc.data()?.phone || '',
            message: 'LAPORAN ANDA DITERIMA. RESPONDER MENUJU LOKASI',
          },
        };

        try {
          await messaging.send({
            token: reporterToken,
            ...payload,
          });
        } catch (error) {
          console.error('Error sending SOS_ACK:', error);
        }
      }
    }

    // Kirim STOP_SIREN ke responder lain
    const allRespondersSnapshot = await db
      .collection('responders')
      .where('status', '==', 'Tersedia')
      .get();

    const otherTokens = allRespondersSnapshot.docs
      .map((doc) => {
        if (doc.id !== responderId) {
          return doc.data().fcmToken;
        }
        return null;
      })
      .filter((token) => token != null);

    if (otherTokens.length > 0) {
      const stopPayload = {
        data: {
          type: 'STOP_SIREN',
          reportId: reportId,
        },
      };

      try {
        await messaging.sendToDevice(otherTokens, stopPayload);
      } catch (error) {
        console.error('Error sending STOP_SIREN:', error);
      }
    }

    return { ok: true };
  });
});

/**
 * Callable function untuk stop sirene (dipanggil saat cancel SOS).
 */
exports.stopSiren = functions.https.onCall(async (data, context) => {
  const { reportId } = data;
  if (!reportId) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'reportId is required'
    );
  }

  // Kirim STOP_SIREN ke semua responder
  const respondersSnapshot = await db.collection('responders').get();
  const tokens = respondersSnapshot.docs
    .map((doc) => doc.data().fcmToken)
    .filter((token) => token != null);

  if (tokens.length > 0) {
    const payload = {
      data: {
        type: 'STOP_SIREN',
        reportId: reportId,
      },
    };

    try {
      await messaging.sendToDevice(tokens, payload);
    } catch (error) {
      console.error('Error sending STOP_SIREN:', error);
    }
  }

  return { ok: true };
});

