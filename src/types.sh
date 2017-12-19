#!/bin/bash

# Source: types.sh
# Data: 9 de dezembro de 2017
# Desenvolvido por: Juliano Santos [SHAMAN]

[[ $__TYPES_SH ]] && return 0

readonly __TYPES_SH=1

declare -Ag __BUILTIN_TYPE_IMPLEMENTS

__BUILTIN_TYPE_IMPLEMENTS[time]='
time.localtime
time.ctime
'

__BUILTIN_TYPE_IMPLEMENTS[string]='
string.capitalize 
string.center 
string.count 
string.hassuffix 
string.hasprefix 
string.expandtabs 
string.find 
string.rfind 
string.isalnum 
string.isalpha 
string.isdecimal 
string.isdigit 
string.isspace 
string.isprintable 
string.islower 
string.isupper 
string.istitle 
string.join 
string.ljust 
string.rjust 
string.tolower 
string.toupper 
string.trim 
string.ltrim 
string.rtrim 
string.remove 
string.rmprefix 
string.rmsuffix 
string.replace 
string.fnreplace 
string.nreplace 
string.fnnreplace 
string.split 
string.swapcase 
string.totitle 
string.reverse 
string.repeat 
string.zfill 
string.compare 
string.nocasecompare 
string.contains 
string.fnmap 
string.slice 
string.filter
string.len
string.field
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
