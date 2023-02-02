# https://cc65.github.io/doc/apple2enh.html#ss4.1
 
CC65=cc65
CL65=cl65
CA65=ca65
LD65=ld65

INCPATH=/usr/share/cc65/include
CFGPATH=/usr/share/cc65/cfg
CFLAGS=

# need trailing slash
LOADERPATH=/usr/share/cc65/target/apple2/util/
#
LIBPATH=/usr/share/cc65/lib
LINKTYPE=apple2enh
LINKCFG=apple2enh-system2.cfg
LINKLIB=apple2enh.lib

# You may need to change this to where your AppleCommander is installed:
FAC=~/Downloads/AppleCommander.jar
AC=~/Downloads/ac.jar

# Change this to your desired starting address in Apple ][ memory:
ADDR=803

# Put the name of your sourcefile here:
PGM=fdump
VOLNAME=HELLA

# Name of the final disk to add to and launch
DSKBK=TEST.2mg.backup
DSK=TEST.2mg

CSRC = $(wildcard *.c)
SSRC = $(wildcard *.s)
OBJS = $(CSRC:.c=.o) $(SSRC:.s=.o)

all: $(OBJS) $(PGM)

install: $(PGM)

clean:
	rm -f $(PGM)
	rm -f $(PGM).o
	rm -f $(PGM).lst
	rm -f $(PGM).po

#remove the implicit rule (no recipe) want other %.s rule to run
%.o : %.c

%.s : %.c
	echo "compile"
	#$(CC65) -v -C $(LINKCFG) -I $(INCPATH) -g $<
	$(CC65) -v -t $(LINKTYPE) -I $(INCPATH) -g $<
	
%.o : %.s
	echo "assemble"
	$(CA65) -g -t $(LINKTYPE) -l $*.lst $<
	
$(PGM): $(OBJS)
	echo "build"
	$(LD65) -v -vm -m $(PGM).map --dbgfile $(PGM).dgb -C $(LINKCFG) -o $(PGM) $^ $(LINKLIB) 

disk:$(PGM)
	echo "setup disk and run"
	# if not there, don't fail
	touch $(PGM).po
	# remove old disk
	rm $(PGM).po
	# create new disk and put a loader on it (from cc65, "cl65 --print-target-path")
	java -jar $(AC) -pro800 $(PGM).po $(VOLNAME) sys < $(LOADERPATH)loader.system
	java -jar $(AC) -as $(PGM).po $(PGM) bin < $(PGM)

launch:$(PGM)
	echo "run"
	gsplus -config ./config.txt
