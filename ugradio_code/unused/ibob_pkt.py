import struct, numpy as n

def parse_pkt(pktstr):
    accnum = struct.unpack('<I',pktstr[4:8])[0]
    vecnum = struct.unpack('>I',pktstr[9:13])[0]
    d = struct.unpack_from('>256I',pktstr[21:1045])
    return (accnum, vecnum, d)

def parse_pkt_stream(pktstr):
    d = [parse_pkt(pktstr[o:o+1045]) for o in xrange(0,len(pktstr),1045)]
    # Find the beginning of the first whole spectrum
    i = 0
    while d[i][1] != 0: i += 1
    # Find the end of the last whole spectrum
    j = -1
    while d[j][1] != 31: j -= 1
    if j == -1: d = n.array([x[-1] for x in d[i:]])
    else: d = n.array([x[-1] for x in d[i:j+1]])
    d.shape = (d.size/8192,8192)
    return d
        

#import sys, pylab as p
#d = parse_pkt_stream(open(sys.argv[-1]).read())
#print d.shape
#d_avg = n.average(d, axis=0)
##d_avg.shape = (d_avg.size/16,16)
##p.plot(d_avg[:,0])
#p.plot(d_avg)
#p.show()
