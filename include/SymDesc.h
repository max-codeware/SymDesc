#ifndef SYMDESC_H
#define SYMDESC_H

static mrb_value
str_empty_with_capa(mrb_state *mrb, mrb_value self);

void
mrb_mruby_SymDesc_gem_init(mrb_state* mrb);

void
mrb_mruby_SymDesc_gem_final(mrb_state* mrb);

#endif