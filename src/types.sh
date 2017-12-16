#!/bin/bash

# Source: types.sh
# Data: 9 de dezembro de 2017
# Desenvolvido por: Juliano Santos [SHAMAN]

[[ $__TYPES_SH ]] && return 0

readonly __TYPES_SH=1

declare -A __BUILTIN_TYPE_IMPLEMENTS

__BUILTIN_TYPE_IMPLEMENTS[time]='
time.localtime
time.ctime
'

__BUILTIN_TYPE_IMPLEMENTS[str]='
str.capitalize 
str.center 
str.count 
str.hassuffix 
str.hasprefix 
str.expandtabs 
str.find 
str.rfind 
str.isalnum 
str.isalpha 
str.isdecimal 
str.isdigit 
str.isspace 
str.isprintable 
str.islower 
str.isupper 
str.istitle 
str.join 
str.ljust 
str.rjust 
str.tolower 
str.toupper 
str.trim 
str.ltrim 
str.rtrim 
str.remove 
str.rmprefix 
str.rmsuffix 
str.replace 
str.fnreplace 
str.nreplace 
str.fnnreplace 
str.split 
str.swapcase 
str.totitle 
str.reverse 
str.repeat 
str.zfill 
str.compare 
str.nocasecompare 
str.contains 
str.map 
str.slice 
str.filter
str.len
str.field
'

__BUILTIN_TYPE_IMPLEMENTS[array]='
array.append 
array.clear 
array.copy 
array.clone 
array.count 
array.items 
array.index 
array.insert 
array.pop 
array.remove 
array.removeall 
array.reverse 
array.len 
array.sort 
array.join 
array.item 
array.contains 
array.reindex 
array.slice
array.listindex
array.list
'

__BUILTIN_TYPE_IMPLEMENTS[map]='
map.clone
map.copy
map.fromkeys
map.get
map.keys
map.items
map.list
map.remove
map.add
map.contains
map.pop
'

__BUILTIN_TYPE_IMPLEMENTS[regex]='
regex.findall
regex.fullmatch 
regex.match 
regex.search 
regex.split 
regex.ismatch 
regex.groups 
regex.savegroups 
regex.replace
regex.nreplace 
regex.fnreplace 
regex.fnnreplace
'

__BUILTIN_TYPE_IMPLEMENTS[file]='
os.file.name
os.file.stat
os.file.fd
os.file.readlines
os.file.readline
os.file.read
os.file.writeline
os.file.write
os.file.close
os.file.tell
os.file.mode
os.file.seek
os.file.size
os.file.isatty
os.file.writable
os.file.readable
os.file.rewind
'

__BUILTIN_TYPE_IMPLEMENTS[filepath]='
filepath.dirname
filepath.basename
filepath.glob
filepath.relpath
filepath.ext
filepath.splitlist
filepath.split
filepath.slash
filepath.join
filepath.scandir
filepath.walk
filepath.exists
filepath.match
filepath.copy
'

__BUILTIN_TYPE_IMPLEMENTS[fileinfo]='
filepath.fileinfo.name
filepath.fileinfo.size
filepath.fileinfo.mode
filepath.fileinfo.modtime
filepath.fileinfo.modstime
filepath.fileinfo.isdir
filepath.fileinfo.perm
filepath.fileinfo.ext
filepath.fileinfo.type
filepath.fileinfo.inode
filepath.fileinfo.path
filepath.fileinfo.gid
filepath.fileinfo.group
filepath.fileinfo.uid
filepath.fileinfo.user
'

__BUILTIN_TYPE_IMPLEMENTS[user]='
user.groups
user.gids
user.id
'

__BUILTIN_TYPE_IMPLEMENTS[group]='
grp.passwd
grp.members
grp.gid
grp.info
'

readonly __BUILTIN_TYPE_IMPLEMENTS

# /* __TYPES_SH */
