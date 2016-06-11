module.exports = class Neko {

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
