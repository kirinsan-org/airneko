/**
 * 仮想ネコ
 */
const db = require('./lib/db.js');

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

class Neko {

  constructor(ref) {
    this.ref = ref;

    /**
     * Firebaseの更新をthis.valueに保存する
     */
    ref.on('value', snapshot => {
      this.value = snapshot.val();
    });
  }

  /**
   * 場所を設定する
   */
  setPlace(place) {
    console.log('setPlace', place);
    return this.ref.child('place').set(place);
  }

  getPlace() {
    return this.value && this.value.place;
  }

  /**
   * 状態を設定する
   */
  setState(state) {
    console.log('setState', state);
    return this.ref.child('state').set(state);
  }

  getState() {
    return this.value && this.value.state;
  }

  /**
   * 空腹度を設定する
   */
  setHungry(hungry) {
    console.log('setHungry', hungry);
    return this.ref.child('hungry').set(hungry);
  }

  getHungry() {
    return this.value && this.value.hungry;
  }

  /**
   * うんこ度を設定する
   */
  setUnko(unko) {
    console.log('setUnko', unko);
    return this.ref.child('unko').set(unko);
  }

  getUnko() {
    return this.value && this.value.unko;
  }

  /**
   * 空腹度を加算する
   */
  addHungry(value) {
    console.log('addHungry', value);
    return this.ref.child('hungry').transaction(currentVal => {
      return currentVal + value;
    });
  }

  /**
   * うんこ度を加算する
   */
  addUnko(value) {
    console.log('addUnko', value);
    return this.ref.child('unko').transaction(currentVal => {
      return currentVal + value;
    });
  }

  /**
   * なつき度を設定する
   */
  setNatsuki(memberId, value) {
    console.log('setNatsuki', memberId, value);
    return this.ref.child('natsuki').child(memberId).set(value);
  }

  getNatsuki(memberId) {
    return this.value && this.value.natsuki && this.value.natsuki[memberId];
  }

  /**
   * なつき度を加算する
   */
  addNatsuki(memberId, value) {
    console.log('addNatsuki', memberId, value);
    return this.ref.child('natsuki').child(memberId).transaction(currentVal => {
      return currentVal + value;
    });
  }
}

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
    let nextState = randomChoose(status);
    if (nextState) {
      neko.setState(nextState);
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
    if (place) {
      bomb(place);
      neko.setUnko(0);
    }
  }

  // TODO 空腹度をチェックして、ランダム確率でいたずらをする。

  setTimeout(loop, stateUpdateInterval);
}

loop();