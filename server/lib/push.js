const db = require('./db.js');

/**
 * 全てのデバイスIDを取得する
 */
function getAllDeviceIds() {
  return db.ref('family/sample/token').once('value')
    .then(snapshot => {
      let allDeviceIds = [];
      snapshot.forEach(child => allDeviceIds.push(child.key));
      return allDeviceIds;
    });
}

/**
 * にゃー通知を送る
 */
module.exports = class NotificationSender {
  static sendNotification() {
    getAllDeviceIds()
      .then(allDeviceIds => {

        let num = Math.floor(Math.random() * 8) + 1; // 1-8のランダム

        // プッシュ通知送信
        request({
          url: 'https://fcm.googleapis.com/fcm/send',
          method: 'POST',
          headers: {
            'Authorization': 'key=AIzaSyDIKt6VXPNblUTdMCbBrNT5Gni6dPkM1R8'
          },
          json: true,
          body: {
            // 全てのデバイスIDを宛先にする
            "registration_ids": allDeviceIds,
            // "to": "djxmqTa6dWM:APA91bGrXqDQmvDW1nrjlKAut636IuEmUpmFSGkezYO5Z1E7P_vk-Pmv3zLM0-Cc1ArV0rbDUCob0ng-PbDz-kW_RhjLcWrN_Lz72GuPdH0Ph0hC-Ki0WKdy-vG9PDg_ihlYYe7zS7NH",
            "priority": "high",
            "notification": {
              "title": "エアねこ",
              "body": "にゃー",
              "sound": `nyaa${num}.wav`
            }
          }
        }, (err, res) => {
          console.log(err, res && res.toJSON && res.toJSON());
        });
      });
  }
}