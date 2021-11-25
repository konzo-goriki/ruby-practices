#! /bin/zsh

echo 'test files setuped'

for i in {1..20}; do
  rand=`shuf -i 4-16 -n 1`
  str=`cat /dev/urandom | LC_CTYPE=C tr -d -c '[:alnum:]' | fold -w ${rand} | head -n 1`
  val=`printf ${i}_${str}`
  echo ${val} > ${val}.txt
done

mkdir test_dir1

for i in {1..20}; do
  rand=`shuf -i 4-16 -n 1`
  str=`cat /dev/urandom | LC_CTYPE=C tr -d -c '[:alnum:]' | fold -w ${rand} | head -n 1`
  val=`printf test_dir1/${i}_${str}`
  echo ${val} > ${val}.txt
done
