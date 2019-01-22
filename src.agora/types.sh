#!/bin/bash

# Source: types.sh
# Data: 9 de dezembro de 2017
# Desenvolvido por: Juliano Santos [SHAMAN]

[[ $__TYPES_SH ]] && return 0

readonly __TYPES_SH=1

declare -Ag __BUILTIN_TYPE_IMPLEMENTS

__BUILTIN_TYPE_IMPLEMENTS[builtin]='
builtin.__len__
builtin.__quote__
builtin.__typeval__
builtin.__isnum__
builtin.__isnull__
builtin.__in__
builtin.__dec__
builtin.__eq__
builtin.__ne__
builtin.__gt__
builtin.__lt__
builtin.__ge__
builtin.__le__
builtin.__float__
builtin.__iter__
builtin.__fnmap__
builtin.__fn__
builtin.__upper__
builtin.__lower__
builtin.__rev__
builtin.__repl__
builtin.__rm__
builtin.__swap__
'

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
filepath.ext
filepath.basename
filepath.dirname
filepath.relpath
filepath.split
filepath.splitlist
filepath.slash
filepath.ismatch
filepath.match
filepath.exists
filepath.listdir
filepath.scandir
filepath.fnscandir
filepath.fnlistdir
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
user.pass
user.uid
user.gid
user.gecos
user.home
user.shell
'

__BUILTIN_TYPE_IMPLEMENTS[group]='
grp.getgrgid
grp.getgrusers
grp.getgrpass
'

__BUILTIN_TYPE_IMPLEMENTS[struct]='
struct.
struct.add
struct.set
struct.members
'

readonly __BUILTIN_TYPE_IMPLEMENTS

# /* __TYPES_SH */
