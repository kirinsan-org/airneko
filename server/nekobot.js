/**
 * 仮想ネコ
 */
const request = require('request');
const db = require('./lib/db.js');
const Neko = require('./Neko.js');
const NotificationSender = require('./lib/push.js');

let familyRef = db.ref('family/sample');
let nekoRef = familyRef.child('neko/sampleneko');
// nekoRef.on('value', snapshot => {
//   console.log('neko', snapshot.val());
// });

/**
 * 自動で遷移する状態の一覧
 */
let status = ['sleeping', 'angry', 'yawn', 'delightful'];

/**
 * メンバーの一覧
 */
let memberRef = familyRef.child('member');
let members;
memberRef.on('value', snapshot => {
  members = snapshot.val();
});

/**
 * 状態変更ループの間隔
 */
let stateUpdateInterval = 3000;

/**
 * @param probability 0-1でtrueになる確立を与える
 * @returns boolean 
 */
function rnd(probability) {
  return Math.random() < probability;
}

/**
 * 配列のいずれかの要素をランダムに取得する
 */
function randomChoose(array) {
  let index = Math.floor(Math.random() * array.length);
  return array[index];
}

/**
 * 指定したメンバーのところにうんこをする
 */
function bomb(memberId) {
  memberRef.child(memberId).child('item').set('unko');
}

function itazura() {
  // 誰かのところにGを置く
  if (rnd(0.5)) {
    let memberId = randomChoose(Object.keys(members));
    if (memberId) {
      memberRef.child(memberId).child('item').set('g');
    }
  } else {
    // ツイートする
    familyRef.child('ifttt/test').once('value')
      .then(snapshot => {
        let requestParams = snapshot.val();
        if (requestParams) {
          request(requestParams, (err, res) => {
            console.log(err, res && res.toJSON && res.toJSON());
          });
        }
      });
  }
}

let neko = new Neko(nekoRef);

/**
 * 一定間隔で行う処理
 */
function loop() {

  // 食事中だったらうんこ度が増える。空腹度は下がる。
  if (neko.getState() === 'eating') {
    neko.addUnko(0.1);
    neko.addHungry(-0.1);
  }

  // 状態が変わる
  if (rnd(0.1)) {

    // いたずらかどうかをまず判定する
    let isEscapade = rnd(neko.getHungry()); // 空腹度が高いほどいたずらになりやすい
    if (isEscapade) {

      // いたずらを実行する。
      neko.setPlace('other'); // いたずらを実行する時は誰の場所にも現れない。
      neko.setState('escapade');
      NotificationSender.sendNotification(); // いたずらしていることを通知する

      // 誰かのところにGを置く
      itazura();

    } else {

      // ランダムに状態遷移する
      let nextState = randomChoose(status);
      if (nextState) {
        neko.setState(nextState);
      }

    }
  }

  // 食事中、じゃれ中、寝ている以外の場合は移動するかも
  if (members
    && neko.getState() !== 'eating'
    && neko.getState() !== 'playful'
    && neko.getState() !== 'sleeping') {

    // 1. ねこじゃらしをしている人がいたら一定の確率でその人の場所へ移動し、じゃれている状態にする。
    //    移動が起きた場合はねこじゃらしが画面から消える
    // 2. えさを置いている人がいたら一定の確率でその人の場所へ移動し、食事状態にする。
    //    移動が起きた場合はえさが画面から消える

    let moved = false; // 移動が発生した場合はtrueになる

    for (let memberId in members) {
      let member = members[memberId];

      // ねこじゃらしを表示しているかどうか
      if (member.item === 'setaria') {
        if (rnd(0.5)) {
          neko.setPlace(memberId);
          neko.setState('playful');
          memberRef.child(memberId).child('item').set('none');
          moved = true;
        }
      }
      // えさを表示しているかどうか
      else if (member.item === 'feed') {
        // 移動確率は空腹度が高い程高い
        if (rnd(neko.getHungry())) {
          neko.setPlace(memberId);
          neko.setState('eating');
          memberRef.child(memberId).child('item').set('none');

          // なつき度が上がるかも
          if (rnd(0.5)) {
            neko.addNatsuki(memberId, 10);
          }
          moved = true;
        }
      }
    }

    // どこにも移動しなかったときは、ランダムで場所が変わるかも
    if (!moved) {
      if (rnd(0.1)) {
        let ids = Object.keys(members);
        let nextId = randomChoose(ids);
        if (nextId) {
          neko.setPlace(nextId);

          // ランダムに状態遷移する
          let nextState = randomChoose(status);
          if (nextState) {
            neko.setState(nextState);
          }
        }
      }
    }
  }

  // 空腹度が増える
  neko.addHungry(0.001);

  // うんこ度をチェックして、うんこ度が1を超えていたらうんこする。うんこ度は0になる。
  if (neko.getUnko() >= 1) {
    let place = neko.getPlace();
    if (place && members[place]) {
      bomb(place);
      neko.setUnko(0);
      neko.setState('unko');
    }
  }

  setTimeout(loop, stateUpdateInterval);
}

loop();