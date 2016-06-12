const db = require('../lib/db.js');

let statusRef = db.ref('status');
let familyRef = db.ref('family/sample');
let memberRef = familyRef.child('member');
memberRef.on('value', snapshot => {
  console.log('member', snapshot.val());
});

let nekoRef = familyRef.child('neko/sampleneko');
nekoRef.on('value', snapshot => {
  console.log('neko', snapshot.val());
});

angular.module('App', ['firebase'])
  .controller('Main', ($scope, $firebaseObject) => {

    $scope.members = $firebaseObject(memberRef);
    $firebaseObject(nekoRef).$bindTo($scope, 'neko');
    $scope.status = $firebaseObject(statusRef);

    /**
     * 居場所を変える
     */
    $scope.setPlace = (place) => {
      $scope.neko.place = place;
    };

    /**
     * 状態を変える
     */
    $scope.setState = (state) => {
      $scope.neko.state = state;
    };

    /**
     * 空腹度を操作する
     */
    $scope.addHungry = (value) => {
      $scope.neko.hungry += value;
    };

    /**
     * うんこ度を操作する
     */
    $scope.addUnko = (value) => {
      $scope.neko.unko += value;
    };

  });