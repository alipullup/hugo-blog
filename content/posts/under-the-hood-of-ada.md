---
title: "Under the Hood of Ada"
date: 2005-04-01
draft: false
---


# Introduction

The following is an old document I wrote when debugging the GCC Ada front-end for MIPS. Our platform was not officially supported and I was tasked with finding and fixing various issued related to exceptions, and tasking.

I've used that `-gnatG` switch to look at the processed source produced by GNAT and done some analysis. What follows is a summary and highlights from that analysis.

# Exceptions

The exception

{{< highlight ada >}}
Blocking_Error : exception;
{{< / highlight >}}


This is turned into

{{< highlight ada >}}

subtype disk__fpga__Tblocking_errorES is string (1 .. 25);
   disk__fpga__blocking_errorE : constant string (1 .. 25) :=
     "DISK.FPGA.BLOCKING_ERROR["00"]";
   disk__fpga__R2s : constant access_character := access_character!(
     disk__fpga__blocking_errorE'address);
   disk__fpga__blocking_error : exception;
   system__exception_table__register_exception (
     system__standard_library__exception_data_ptr!(
     disk__fpga__blocking_error'unrestricted_access));
{{< / highlight >}}

That's all exceptions seem to be under the hood.

# Records, Arrays and Discreet Types

Records are represented very efficiently. I see no overhead, and they seem to work just like C style structures.

The same holds true for arrays and and floating and integer types.

# Enumeration Types

Enumeration types are surprisingly efficient. Basically whenever you declare an enumeration:

{{< highlight ada >}}
type myenum is (somevalue, othervalue);
{{< / highlight >}}

It's turned into:

{{< highlight ada >}}
type myenum is (somevalue, othervalue);
myenumS : constant string (1 .. 19) := "SOMEVALUEOTHERVALUE" ;
myenumI : constant array  (0 .. 2 ) of integer_8 := (1, 10 20);
{{< / highlight >}}

So it's quite easy to figure out the string or integer value of an enumeration type.

# Initialization of Types

It seems that a decent sized chunk of code is generated every time we have a record type with a default value in there, e.g.

{{< highlight ada >}}
    type my_record is record
        something : some_type := some_value;
    end record;
{{< / highlight >}}

Ada will generate code wherever this type is declared, and also any time this record is part of another record, the other record will have code generated as well.

{{< highlight ada >}}
    type other_record is record
        my_record_type : my_record; -- no default value
    end record;
{{< / highlight >}}

Will still have code generated to initialize it. This will cause the overhead of two function calls. 

1. To initialize `other_record` which will 
2. Call the code to initialize 'my_record'.

It's especially bad in arrays, e.g.

{{< highlight ada >}}
type other_record_array is (integer range ) of other_record;
{{< / highlight >}}

will end up generating something like:

{{< highlight ada >}}
procedure initialize_other_array (x : other_reccord_array) is
begin
    for i in x'range loop
        procedure_to_initialize_other_record (x(i));
    end loop;
end;
{{< / highlight >}}

So we get `Array'Length * 2` function calls in this case to create the array.

# Protected Types / Objects

These seem to be implemented in a pretty straight forward manner.

*   There is a mutex placed in the package
*   For all publically visibile procedures / functions, a N and P version are declared. The N is non protected version, and the P is the protected version.
*   For all private procedures / function, an N version is declared.

Let me illustrate:

{{< highlight ada >}}
package foo is
    protected bar is
        function x return boolean;
    private
        function y return boolean;
    end bar;
end foo;
{{< / highlight >}}

Gets turned into:

{{< highlight ada >}}
package foo is
    protected type barT is
        function x return boolean;
    private
        function y return boolean;
    end bar;
    bar : barT;
    type foo__barTV is limited record
        _object : aliased
            system__tasking__protected_objects__protection;
    end record;
    -- Code to initialize barT, which will set up its priority
    -- and initialize foo__barTV.  I don't know where an instance
    -- of the  object foo__barTV is actually declared.
    function foo__barT__xN(_object : in out  foo__barTV)
        return boolean;
    function foo__barT__xP(_object : in out  foo__barTV)
        return boolean;
    function foo__barT__yN(_object : in out  foo__barTV)
        return boolean;
end foo;
{{< / highlight >}}

# Overhead with Protected Types

As we've seen, there is a `P` (protected) version of all functions and procedures declared. Here is what the body of a null procedure (body is just 'null') is expanded to:

NOTE: The procedure was called `p`, and it was in a procedure called test that declared a type `test_type`.

{{< highlight ada >}}
procedure test__test_typePT__pP (_object : in out test__test_typeTV) is
   procedure test__test_typePT__pP___clean is
   begin
      system__tasking__protected_objects__unlock (_object._object'
        unchecked_access);
      system__soft_links__abort_undefer.all;
      return;
   end test__test_typePT__pP___clean;
begin
   system__soft_links__abort_defer.all;
   system__tasking__protected_objects__lock (_object._object'
     unchecked_access);
   B3b : begin
      test__test_typePT__pN (_object);
   exception
      when all others =>
         B6b : declare
            E5b : ada__exceptions__exception_occurrence;
         begin
            ada__exceptions__save_occurrence (E5b,
              system__soft_links__get_current_excep.all.all);
            test__test_typePT__pP___clean;
            ada__exceptions__reraise_occurrence_no_defer (E5b);
         end B6b;
   at end
      test__test_typePT__pP___clean;
   end B3b;
   return;
end test__test_typePT__pP;
{{< / highlight >}}

It seems that we should keep our protected types as small as possible. This means 

1. only using protected types when necessary and 
2. keeping the public interface to a protected type as small as possible.

Something strange happens as soon as an entry is added to a protected type. A bunch of code is added that (1) adds a queue per entry, on which tasks will wait to enter the protected type until the entry condition is true (2) and finalization code to clean up after these queues.

There is a notable difference between protected types with no entries, and those with.

# Tasks

Tasks are not lightweight objects. The following components add up rather quickly:

*   Code to initialize a task.
*   Code to clean up after a task.
*   Handling exceptions during

If you want to look at the code generated for a task, try compiling the following:

{{< highlight ada >}}
procedure test is
    task test_task is
        entry Start;
    end test_task;
    task body test_task is
    begin
        accept Start;
        loop
            delay 1.0;
        end loop;
    end test_task;
begin
    test_task.start;
end test;

{{< / highlight >}}

The processed source is 4055 bytes and 117 lines. You can view the code in the appendix.

# Subtypes and Renaming

Subtypes and package / procedure renaming is done in a sane manner. Subtypes are just subtypes, nothing extra is generated, and neither is anything done for renaming.

# Overhead with `T'Image` / `Value'Img` and `Put_Line`

So far, I've only found the following to happen when using `T'Image` for some type `T`, and `Value'Image`, for some variable or constant `Value`.

Here is the typical code (in a procedure called `test`):

{{< highlight ada >}}
procedure test1 is
    t1 : constant integer := 1;
begin
    ada.text_io.put_line(t1'img);
end test1;
{{< / highlight >}}

For some reason, GNAT is turning this into the following horrific procedure:

{{< highlight ada >}}
procedure test__test1 is
   M5b : system__secondary_stack__mark_id :=
     system__secondary_stack__ss_mark;
   procedure test__test1___clean is
   begin
      system__secondary_stack__ss_release (M5b);
      return;
   end test__test1___clean;
begin
   t1 : constant integer := 1;
   B4b : declare
   begin
      ada.ada__text_io.ada__text_io__put_line (
        system__img_int__image_integer (t1));
   end B4b;
   return;
exception
   when all others =>
      B7b : declare
         E6b : ada__exceptions__exception_occurrence;
      begin
         ada__exceptions__save_occurrence (E6b,
           system__soft_links__get_current_excep.all.all);
         test__test1___clean;
         ada__exceptions__reraise_occurrence_no_defer (E6b);
      end B7b;
      return;
at end
   test__test1___clean;
end test__test1;
{{< / highlight >}}

I have looked at other places where exceptions are raised, and haven't found the above. I don't understand the reason for why the above is happening. It's especially bad if a small function calls `'Image` or `'Img`. 
It seems that much larger functions, or functions that make liberal use of `T'Image` or `Value'Img`, would be able to make up for the cost of all this junk by doing enough work.

Some things worth noting:

* Putting a `To_String (Value : T)` return String function in a package to convert the type to a string doesn't seem to do the trick. We still end up with all this exception junk, and the secondary stack the caller.
* Putting an entire `Put (Value : T)` in another package does seem to work.
* _Each block_ that has a `T'Img` seems to get all the junk. This is especially bad if there are many small functions or small blocks that call the `'Img`.
* _Each for loop_ is equivalent to a block, in the sense that a begin and end is generated for each for loop and all this junk is put in that block. 
  Many places have an outside for loop that has an inner block, that again has a for loop. This adds up to at least three blocks that have all this junk associated with them.
  The inner blocks are allocated upon each iteration of the loop.

# Appendix

Code generated for the dummy task.

{{< highlight ada >}}
with system.system__parameters;
with system.system__tasking;
with system.system__task_info;
with system.system__tasking.system__tasking__stages;
with system;
with system.system__soft_links;
with system.system__tasking.system__tasking__rendezvous;
with ada.ada__calendar.ada__calendar__delays;
with ada.ada__exceptions;
procedure test is
   procedure test___clean is
   begin
      system__soft_links__abort_defer.all;
      system__soft_links__complete_master.all;
      system__soft_links__abort_undefer.all;
      return;
   end test___clean;
begin
   system__soft_links__enter_master.all;
   _chain : aliased system__tasking__activation_chain;
   system__tasking___init_proc (_chain);
   task type test__test_taskTK is
      entry start;
   end test__test_taskTK;
   test_taskTKE : aliased boolean := false;
   test_taskTKZ : system__parameters__size_type :=
     system__parameters__unspecified_size;
   type test__test_taskTKV is limited record
      _task_id : system__tasking__task_id;
   end record;
   procedure test__test_taskTKB (_task : access test__test_taskTKV);
   freeze test__test_taskTKV [
      procedure test___init_proc (_init : in out test__test_taskTKV;
        _master : system__tasking__master_id; _chain : in out
        system__tasking__activation_chain; _task_id : in
        system__task_info__task_image_type) is
      begin
         _init._task_id := null;
         system__tasking__stages__create_task (
           system__tasking__unspecified_priority, test_taskTKZ,
           system__task_info__unspecified_task_info, 1, _master,
           system__tasking__task_procedure_access!(test__test_taskTKB'
           address), _init'address, test_taskTKE'unchecked_access,
           _chain, _task_id, _init._task_id);
         return;
      end test___init_proc;
   ]
   _master : constant system__tasking__master_id :=
     system__soft_links__current_master.all;
   test_task : test__test_taskTK;
   test_taskI : system__task_info__task_image_type := new string'"test_task";
   test___init_proc (test__test_taskTKV!(test_task), _master, _chain,
     test_taskI);
   procedure test__test_taskTKB (_task : access test__test_taskTKV) is
      procedure test__test_taskTK___clean is
      begin
         system__soft_links__abort_defer.all;
         system__tasking__stages__complete_task;
         system__soft_links__abort_undefer.all;
         return;
      end test__test_taskTK___clean;
   begin
      system__soft_links__abort_undefer.all;
      L_1 : label
      system__tasking__stages__complete_activation;
      system__tasking__rendezvous__accept_trivial (1);
      L_1 : loop
         ada__calendar__delays__delay_for (100000000.0E-8);
      end loop L_1;
      return;
   exception
      when all others =>
         B7b : declare
            E6b : ada__exceptions__exception_occurrence;
         begin
            ada__exceptions__save_occurrence (E6b,
              system__soft_links__get_current_excep.all.all);
            test__test_taskTK___clean;
            ada__exceptions__reraise_occurrence_no_defer (E6b);
         end B7b;
         return;
   at end
      test__test_taskTK___clean;
   end test__test_taskTKB;
   test_taskTKE := true;
   system__tasking__stages__activate_tasks (_chain'unchecked_access);
   B9b : declare
      X : system__tasking__task_entry_index := 1;
   begin
      system__tasking__rendezvous__call_simple (test__test_taskTKV!(
        test_task)._task_id, X, system__null_address);
   end B9b;
   return;
exception
   when all others =>
      B12b : declare
         E11b : ada__exceptions__exception_occurrence;
      begin
         ada__exceptions__save_occurrence (E11b,
           system__soft_links__get_current_excep.all.all);
         test___clean;
         ada__exceptions__reraise_occurrence_no_defer (E11b);
      end B12b;
      return;
at end
   test___clean;
end test;
{{< / highlight >}}