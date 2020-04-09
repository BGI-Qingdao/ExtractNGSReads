.PNONY: all clean

all:filterPairFQ

headers=utils/argsparser.h \
		utils/fastq.h \
		utils/file_reader.h \
		utils/file_writer.h \
		utils/flags.h \
		utils/gzstream.h \
		utils/stringtools.h \
		utils/seq.h \
		utils/stringtools.h \
		utils/Error.h 

objs_cpp=utils/fastq.cpp \
	 utils/file_reader.cpp \
	 utils/file_writer.cpp \
	 utils/gzstream.cpp \
	 utils/seq.cpp \
	 utils/stringtools.cpp

objs_o = ${objs_cpp:%.cpp=%.o}

.cpp.o:
	g++ -std=c++11 -c $< -o $@

filterPairFQ: ${objs_o} filterPairFQ.cpp ${headers}
	g++ -std=c++11 filterPairFQ.cpp ${objs_o} -lz -o filterPairFQ

