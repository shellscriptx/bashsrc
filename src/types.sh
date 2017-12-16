#!/bin/bash

# Source: types.sh
# Data: 9 de dezembro de 2017
# Desenvolvido por: Juliano Santos [SHAMAN]

[[ $__TYPES_SH ]] && return 0

readonly __TYPES_SH=1

declare -A __BUILTIN_TYPE_IMPLEMENTS

__BUILTIN_TYPE_IMPLEMENTS[time]='
localtime
ctime
'

__BUILTIN_TYPE_IMPLEMENTS[str]='
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
field
'

__BUILTIN_TYPE_IMPLEMENTS[array]='
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

__BUILTIN_TYPE_IMPLEMENTS[map]='
clone
copy
fromkeys
get
keys
items
list
remove
add
contains
pop
'

__BUILTIN_TYPE_IMPLEMENTS[regex]='
findall
fullmatch 
match 
search 
split 
ismatch 
groups 
savegroups 
replace
nreplace 
fnreplace 
fnnreplace
'

__BUILTIN_TYPE_IMPLEMENTS[os.file]='
name
stat
fd
readlines
readline
read
writeline
write
close
tell
mode
seek
size
isatty
writable
readable
rewind
'

__BUILTIN_TYPE_IMPLEMENTS[filepath]='
dirname
basename
glob
relpath
ext
splitlist
split
slash
join
scandir
walk
exists
match
copy
'

__BUILTIN_TYPE_IMPLEMENTS[filepath.fileinfo]='
name
size
mode
modtime
modstime
isdir
perm
ext
type
inode
path
gid
group
uid
user
'

__BUILTIN_TYPE_IMPLEMENTS[user]='
groups
gids
id
'

readonly __BUILTIN_TYPE_IMPLEMENTS

# /* __TYPES_SH */
