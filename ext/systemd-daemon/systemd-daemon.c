#include <ruby.h>

#ifdef HAVE_SYSTEMD_SD_DAEMON_H
#include <systemd/sd-daemon.h>
#endif

#ifdef HAVE_SYSTEMD_SD_DAEMON_H
static VALUE _sd_notify(VALUE mod, VALUE unset_env, VALUE state)
{
  const char * sd_state;
  int return_code;

  sd_state = StringValuePtr(state);
  return_code = sd_notify(0, sd_state);

  return INT2FIX(return_code);
}
#else
static VALUE _not_implemented(VALUE mod, VALUE args)
{
  rb_raise(rb_eNotImpError, "systemd-daemon is not supported for this platform");
}
#endif

void Init_sd_native()
{
  VALUE mSD = rb_define_module("SystemdDaemon");
  VALUE mSDNotify = rb_define_module_under(mSD, "Notify");
#ifdef HAVE_SYSTEMD_SD_DAEMON_H
  rb_define_singleton_method(mSDNotify, "_sd_notify", _sd_notify, 2);
#else
  rb_define_singleton_method(mSDNotify, "_sd_notify", _not_implemented, -2);
#endif
}
