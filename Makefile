# Makefile for zavolaj's NativeCall.pm

# targets that do not produce files
.PHONY: clean test libtest help install install-user uninstall \
	uninstall-user

PERL_EXE  = perl
PERL6_EXE = perl6
CP        = $(PERL_EXE) -MExtUtils::Command -e cp
RM_F      = $(PERL_EXE) -MExtUtils::Command -e rm_f
RM_RF     = $(PERL_EXE) -MExtUtils::Command -e rm_rf
TEST_F    = $(PERL_EXE) -MExtUtils::Command -e test_f
# try to make these OS agnostic (ie use the same definition on Unix and Windows)
LIBSYSTEM = $(shell $(PERL6_EXE) -e 'print @*INC[1]')
LIBUSER   = $(shell $(PERL6_EXE) -e 'print @*INC[0]')

# first the default target
lib/NativeCall.pir: lib/NativeCall.pm6
	$(PERL6_EXE) --target=pir --output=lib/NativeCall.pir lib/NativeCall.pm6

lib/libzavolajtest.so: lib/libzavolajtest.c lib/libzavolajtest.h
	cc -o lib/libzavolajtest.o -fPIC -c lib/libzavolajtest.c
	cc -shared -o lib/libzavolajtest.so lib/libzavolajtest.o

#LD_LIBRARY_PATH=./t/lib ld -o t/lib/libzavolajtest.so.1.0 -shared -soname libzavolajtest.so.1 libzavolajtest.o

# TODO: make this work somehow with Microsoft C
lib/libzavolajtest.dll: lib/libzavolajtest.c lib/libzavolajtest.h
	cc -o lib/libzavolajtest.o -fPIC -c lib/libzavolajtest.c
	cc -shared -o lib/libzavolajtest.so lib/libzavolajtest.o

clean:
	@# delete compiled files
	$(RM_F) lib/*.pir lib/*.o lib/*.so
	@# delete all editor backup files
	$(RM_F) *~ lib/*~ t/*~ t/lib/*~

test: lib/NativeCall.pir lib/libzavolajtest.so
	env PERL6LIB=lib LD_LIBRARY_PATH=lib prove -e $(PERL6_EXE) -r t/

# standard install is to the shared system wide directory
install: lib/NativeCall.pir
	@echo "--> $(LIBSYSTEM)"
	@$(CP) lib/NativeCall.pm6 lib/NativeCall.pir $(LIBSYSTEM)

# if user has no permission to install globally, try a personal directory 
install-user: lib/NativeCall.pir
	@echo "--> $(LIBUSER)"
	@$(CP) lib/NativeCall.pm6 lib/NativeCall.pir $(LIBUSER)

# standard uninstall from the shared system wide directory
uninstall:
	@echo "x-> $(LIBSYSTEM)"
	@$(TEST_F) $(LIBSYSTEM)/NativeCall.pm6
	@$(RM_F)   $(LIBSYSTEM)/NativeCall.pm6
	@$(TEST_F) $(LIBSYSTEM)/NativeCall.pir
	@$(RM_F)   $(LIBSYSTEM)/NativeCall.pir

# uninstall from the user's own Perl 6 directory
uninstall-user:
	@echo "x-> $(LIBUSER)"
	@$(TEST_F) $(LIBUSER)/NativeCall.pm6
	@$(RM_F)   $(LIBUSER)/NativeCall.pm6
	@$(TEST_F) $(LIBUSER)/NativeCall.pir
	@$(RM_F)   $(LIBUSER)/NativeCall.pir

help:
	@echo
	@echo "You can make the following in 'zavolaj':"
	@echo "test           runs a local test suite"
	@echo "libtest        creates and tests a custom library"
	@echo "clean          removes compiled, temporary and backup files"
	@echo "install        copies .pm6 and .pir file(s) to system lib/"
	@echo "               (may need admin or root permission)"
	@echo "uninstall      removes .pm6 and .pir file(s) from system lib/"
	@echo "install-user   copies .pm6 and .pir file(s) to user's lib/"
	@echo "uninstall-user removes .pm6 and .pir file(s) from user's lib/"

