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

angular.module('App', [])
  .factory('nekoRef', _ => {
    return db.ref('family/sample/neko/sampleneko');
  })
  .controller('Main', ($scope) => {

    memberRef.on('value', snapshot => {
      $scope.members = snapshot.val();
      $scope.$apply();
    });

    nekoRef.on('value', snapshot => {
      $scope.neko = snapshot.val();
      $scope.$apply();
    });

    statusRef.on('value', snapshot => {
      $scope.status = snapshot.val();
      $scope.$apply();
    })

    /**
     * 居場所を変える
     */
    $scope.setPlace = (place) => {
      nekoRef.child('place').set(place);
    };

    /**
     * 状態を変える
     */
    $scope.setState = (state) => {
      nekoRef.child('state').set(state);
    };

    /**
     * 空腹度を操作する
     */
    $scope.addHungry = (value) => {
      nekoRef.child('hungry').transaction(currentVal => {
        return currentVal + value;
      });
    };

    /**
     * うんこ度を操作する
     */
    $scope.addUnko = (value) => {
      nekoRef.child('unko').transaction(currentVal => {
        return currentVal + value;
      });
    };

  });