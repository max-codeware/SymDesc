#include <mruby.h>
#include <stdio.h>
#include <mruby/string.h>



static mrb_value
str_empty_with_capa(mrb_state *mrb, mrb_value self)
{
	mrb_int capa;
	mrb_get_args(mrb, "i", &capa);
    return mrb_str_new_capa(mrb,capa);   
}

void
mrb_mruby_SymDesc_gem_init(mrb_state* mrb) {
  struct RClass *s = mrb->string_class;
  mrb_define_class_method(mrb, s, "buffer", str_empty_with_capa, 1);
}

void
mrb_mruby_SymDesc_gem_final(mrb_state* mrb) {
  /* finalizer */
}