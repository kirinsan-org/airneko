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
 * 自動で遷移する状態の一覧
 */
let status = ['sleeping', 'angry', 'yawn', 'delightful'];

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
  memberRef.child(memberId).child('unko').transaction(currentVal => {
    return currentVal + 1;
  });
}

/**
 * ねこじゃらしを表示しているメンバーを取得する。いなければnull。
 */
function getSateriaMemberId() {
  for (let memberId in members) {
    let member = members[memberId];
    if (member.setaria) {
      return memberId;
    }
  }
  return null;
}

let neko = new Neko(nekoRef);

/**
 * 一定間隔で行う処理
 */
function loop() {

  // 食事中だったらうんこ度が増える
  if (neko.getState() === 'eating') {
    neko.addUnko(0.1);
  }

  // 状態が変わる
  if (rnd(0.1)) {

    // いたずらかどうかをまず判定する
    let isEscapade = rnd(1 - neko.getHungry()); // 空腹度が低いほどいたずらになりやすい
    if (isEscapade) {

      // TODO いたずらを実行する。
      neko.setPlace('other'); // いたずらを実行する時は誰の場所にも現れない。
      neko.setState('escapade');

    } else {

      // ランダムに状態遷移する
      let nextState = randomChoose(status);
      if (nextState) {
        neko.setState(nextState);
      }

    }
  }

  // ねこじゃらしをしている人がいたらその人の場所へ移動し、じゃれている状態にする
  let sateriaMemberId = getSateriaMemberId();
  if (sateriaMemberId) {
    neko.setPlace(sateriaMemberId);
    neko.setState('playful');
  } else {

    // 誰もじゃらしていないときは、ランダムで場所が変わる
    if (rnd(0.1)) {
      let nextMember = randomChoose(members);
      if (nextMember) {
        neko.setPlace(nextMember);

        // ランダムに状態遷移する
        let nextState = randomChoose(status);
        if (nextState) {
          neko.setState(nextState);
        }
      }
    }
  }

  // 空腹度が減る
  if (rnd(0.1)) {
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

  setTimeout(loop, stateUpdateInterval);
}

loop();