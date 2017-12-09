#!/bin/bash

[[ $__TYPES_SH ]] && return 0

readonly __TYPES_SH=1

declare -A __SRC_OBJ_METHOD
declare -A __REG_LIST_VAR

__SRC_OBJ_METHOD[str]='
capitalize 
center 
count 
hassuffix 
hasprefix 
expandtabs 
find 
rfind 
isalnum 
isalpha 
isdecimal 
isdigit 
isspace 
isprintable 
islower 
isupper 
istitle 
join 
ljust 
rjust 
tolower 
toupper 
trim 
ltrim 
rtrim 
remove 
rmprefix 
rmsuffix 
replace 
fnreplace 
nreplace 
fnnreplace 
split 
swapcase 
totitle 
reverse 
repeat 
zfill 
compare 
nocasecompare 
contains 
map 
slice 
filter
len
'

__SRC_OBJ_METHOD[array]='
append 
clear 
copy 
clone 
count 
items 
index 
insert 
pop 
remove 
removeall 
reverse 
len 
sort 
join 
item 
contains 
reindex 
slice 
listindex 
list
'

readonly __SRC_OBJ_METHOD
