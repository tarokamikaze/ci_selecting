#!/usr/bin/env bash
alias de='docker-compose exec tester'
ALL_STAT=0
TEST_DIR=/tmp/test-result
COV_ALL=/tmp/covall.out
FAIL_TESTS=()

mkdir -p $TEST_DIR/cov

#de go get -u bitbucket.org/liamstask/goose/cmd/goose
#de goose -env development up
#de curl https://glide.sh/get | sh && glide install
de go get -u github.com/golang/dep/cmd/dep && dep ensure

for PKG in $(go list ./...); do
  COV_FILENAME=${PKG//\//_}
  COV_PATH=/tmp/$COV_FILENAME.out
  RES=`de go test -race -v -cover -coverprofile=$COV_PATH -tag=heavy $PKG`
  STAT=$?
  echo $RES

  if [[ $RES =~ no test files ]] ;
  then
    echo "no test for $PKG, continue"
    continue
  fi

  docker-compose restart couchbase
  if [ stat -ne 0 ] ;then
    FAIL_TESTS=("${FAIL_TESTS[@]}" $PKG)
    ALL_STAT=$STAT
  fi
  de go cat $COV_PATH >> $COV_ALL
done

echo "creating coverage data as tgz"
COV_ALL_OUT=`de cat $COV_ALL`
echo $COV_ALL_OUT >  $TEST_DIR/cov.out

if [ ${#FAIL_TESTS[*]} -gt 0 ]; then
  echo "fail tests:"
  IFS=$'\n'
  echo "${FAIL_TESTS[*]}"
fi

exit $ALL_STAT
