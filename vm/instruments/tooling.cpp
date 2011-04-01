#include "vm/vm.hpp"
#include "arguments.hpp"
#include "dispatch.hpp"

#include "instruments/rbxti-internal.hpp"
#include "instruments/tooling.hpp"

#include "builtin/compiledmethod.hpp"
#include "builtin/block_environment.hpp"
#include "builtin/variable_scope.hpp"

namespace rubinius {
namespace tooling {

  void ToolBroker::enable(STATE) {
    if(!enable_func_) return;
    enable_func_(state->tooling_env());
  }

  bool ToolBroker::available(STATE) {
    if(enable_func_) return true;
    return false;
  }

  Object* ToolBroker::results(STATE) {
    if(!results_func_) return Qnil;
    return rbxti::s(results_func_(state->tooling_env()));
  }

  void* ToolBroker::enter_method(STATE, Dispatch& msg, Arguments& args, CompiledMethod* cm) {
    if(!enter_method_func_) return 0;

    rbxti::robject recv = rbxti::s(args.recv());
    rbxti::rsymbol name = rbxti::o(msg.name);
    rbxti::rmodule mod =  rbxti::o(msg.module);
    rbxti::rmethod meth = rbxti::o(cm);

    return enter_method_func_(state->tooling_env(), recv, name, mod, meth);
  }

  void ToolBroker::leave_method(STATE, void* tag)
  {
    if(!leave_method_func_) return;

    leave_method_func_(state->tooling_env(), tag);
  }

  void* ToolBroker::enter_block(STATE, BlockEnvironment* env, Module* i_mod)
  {
    if(!enter_block_func_) return 0;

    rbxti::rsymbol name = rbxti::o(env->top_scope()->method()->name());
    rbxti::rmodule mod =  rbxti::o(i_mod);
    rbxti::rmethod meth = rbxti::o(env->method());

    return enter_block_func_(state->tooling_env(), name, mod, meth);
  }

  void ToolBroker::leave_block(STATE, void* tag)
  {
    if(!leave_block_func_) return;
    leave_block_func_(state->tooling_env(), tag);
  }

  void* ToolBroker::enter_gc(STATE, int level)
  {
    if(!enter_gc_func_) return 0;
    return enter_gc_func_(state->tooling_env(), level);
  }

  void ToolBroker::leave_gc(STATE, void* tag)
  {
    if(!leave_gc_func_) return;
    leave_gc_func_(state->tooling_env(), tag);
  }

  void* ToolBroker::enter_script(STATE, CompiledMethod* cm)
  {
    if(!enter_script_func_) return 0;

    rbxti::rmethod meth = rbxti::o(cm);

    return enter_script_func_(state->tooling_env(), meth);
  }

  void  ToolBroker::leave_script(STATE, void* tag)
  {
    if(!leave_script_func_) return;
    leave_script_func_(state->tooling_env(), tag);
  }

  void ToolBroker::set_tool_results(rbxti::results_func func) {
    results_func_ = func;
  }

  void ToolBroker::set_tool_enable(rbxti::enable_func func) {
    enable_func_ = func;
  }

  void ToolBroker::set_tool_enter_method(rbxti::enter_method func) {
    enter_method_func_ = func;
  }

  void ToolBroker::set_tool_leave_method(rbxti::leave_func func) {
    leave_method_func_ = func;
  }

  void ToolBroker::set_tool_enter_block(rbxti::enter_block func)
  {
    enter_block_func_ = func;
  }

  void ToolBroker::set_tool_leave_block(rbxti::leave_func func)
  {
    leave_block_func_ = func;
  }

  void ToolBroker::set_tool_enter_gc(rbxti::enter_gc func)
  {
    enter_gc_func_ = func;
  }

  void ToolBroker::set_tool_leave_gc(rbxti::leave_func func)
  {
    leave_gc_func_ = func;
  }

  void ToolBroker::set_tool_enter_script(rbxti::enter_script func)
  {
    enter_script_func_ = func;
  }

  void ToolBroker::set_tool_leave_script(rbxti::leave_func func)
  {
    leave_script_func_ = func;
  }

}
}