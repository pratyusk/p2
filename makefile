JC = javac
.SUFFIXES: .java .class
.java.class:
	$(JC) $*.java

CLASSES = \
	project2/FakebookOracle.java \
	project2/MyFakebookOracle.java \
	project2/TestFakebookOracle.java

default: classes

classes: $(CLASSES:.java=.class)

clean:
	$(RM) project2/*.class
