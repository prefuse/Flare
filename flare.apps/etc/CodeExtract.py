import os
import stat
import fnmatch
import re

asFile = fnmatch.translate('*.as')

def checkdir(d, prefix):
    map = dict()
    for f in os.listdir(d):
        if re.match(asFile, f):
            map[f[0:len(f)-3]] = 1

    for f in os.listdir(d):
        path = d + os.sep + f
        fileStats = os.stat(path)
        if stat.S_ISDIR(fileStats[stat.ST_MODE]):
            if len(prefix)==0:
                pre = f
            else:
                pre = prefix + '.' + f
            checkdir(path, pre)
        elif re.match(asFile, f):
            name = prefix+'.'+f[0:len(f)-3]
            size = fileStats[stat.ST_SIZE]
            s = '{"name":"'+name+'",'+'"size":'+str(size)+','
            s += '"imports":['
            s += parse(prefix, name, path, map) + ']},'
            print s
    
def parse(prefix, name, file, map): # parse an actionscript file
    """Parse an ActionScript file and extract imports"""
    f = open(file, 'r')
    s = ""
    imports = set()
    for line in f:
        line = line.strip()
        if line.startswith('import flare'):
            fimp = line[7:len(line)-1]
            if name != fimp:
                imports.add(fimp)
        else:
            for sib in map.iterkeys():
                fsib = prefix + '.' + sib
                if line.find(sib) >= 0 and name != fsib:
                    imports.add(fsib)

    for imp in imports:
        s += '"'+imp+'",'
    return s[0:len(s)-1]

srcdir = 'c:\\dev\\flare\\flare\\src'
print '['
checkdir(srcdir, '')
print ']'