// http://www.opensource.apple.com/source/ruby/ruby-18.0.1/ruby/ruby.h
// http://libmtag.googlecode.com/svn-history/r31/ruby/trunk/libmtag.c
#include <ruby.h>
#include "bsdiff.c"


VALUE applyDiff(VALUE self,VALUE oldApk,VALUE newApk,VALUE patchFile)
{
    int  argc = 4;  
    char *argv[argc];  
    argv[0] = "bsdiff";  
    argv[1] = StringValueCStr(oldApk);     // old apk file path;
    argv[2] = StringValueCStr(newApk);     // new apk file path;
    argv[3] = StringValueCStr(patchFile);  // patch file path; 
    int ret = makeDiff(argc, argv);
    return INT2NUM(ret);
}

extern "C" void Init_MakeDiffer()
{
    VALUE MakeDiffer = rb_define_module("MakeDiffer");
    rb_define_module_function(MakeDiffer, "applyDiff", RUBY_METHOD_FUNC(applyDiff), 3);
}

