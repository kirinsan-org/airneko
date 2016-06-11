/**
 * 仮想ネコ
 */
const db = require('./lib/db.js');
const Neko = require('./Neko.js');

let familyRef = db.ref('family/sample');
let nekoRef = familyRef.child('neko/sampleneko');
// nekoRef.on('value', snapshot => {
//   console.log('neko', snapshot.val());
// });

/**
 * 状態の一覧
 */
let statusRef = db.ref('status');
let status = [];
statusRef.on('value', snapshot => {
  status = [];
  snapshot.forEach(child => {
    status.push(child.key);
  });
});

/**
 * メンバーの一覧
 */
let memberRef = familyRef.child('member');
let members = [];
memberRef.on('value', snapshot => {
  members = [];
  snapshot.forEach(child => {
    members.push(child.key);
  });
});

/**
 * 状態変更ループの間隔
 */
let stateUpdateInterval = 10000;

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
  memberRef.child(memberId).child('unko').transaction(currentVal => {
    return currentVal + 1;
  });
}

let neko = new Neko(nekoRef);

/**
 * 一定間隔で行う処理
 */
function loop() {

  // 状態が変わる
  if (rnd(0.3)) {

    // いたずらかどうかをまず判定する
    let isEscapade = rnd(1 - neko.getHungry()); // 空腹度が低いほどいたずらになりやすい
    if (isEscapade) {

      // TODO いたずらを実行する。
      neko.setPlace('other'); // いたずらを実行する時は誰の場所にも現れない。
      neko.setState('escapade');

    } else {

      // いたずら以外の状態にランダムに変化する
      let nextState = randomChoose(status);
      if (nextState && nextState !== 'escapade') {
        neko.setState(nextState);
      }

    }
  }

  // 場所が変わる
  if (rnd(0.3)) {
    let nextMember = randomChoose(members);
    if (nextMember) {
      neko.setPlace(nextMember);
    }
  }

  // 空腹度が減る
  if (rnd(0.3)) {
    if (neko.getHungry() > 0) {
      neko.addHungry(-0.05);
    }
  }

  // うんこ度をチェックして、うんこ度が1を超えていたらうんこする。うんこ度は0になる。
  if (neko.getUnko() >= 1) {
    let place = neko.getPlace();
    if (place && members[place]) {
      bomb(place);
      neko.setUnko(0);
    }
  }

  // TODO 空腹度をチェックして、ランダム確率でいたずらをする。

  setTimeout(loop, stateUpdateInterval);
}

loop();