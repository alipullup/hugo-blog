---
title: "Under the Hood of Ada"
date: 2005-04-01
draft: false
---


# Introduction

The following is an old document I wrote when debugging the GCC Ada front-end for MIPS. Our platform was not officially supported and I was tasked with finding and fixing various issued related to exceptions, and tasking.

I’ve used that `-gnatG` switch to look at the processed source produced by GNAT and done some analysis. What follows is a summary and highlights from that analysis.

# Exceptions

The exception

<div class="codehilite">

<pre><span></span>    <span class="n">Blocking_Error</span>              <span class="p">:</span> <span class="kr">exception</span><span class="p">;</span>
</pre>

</div>

This is turned into

<div class="codehilite">

<pre><span></span> subtype disk__fpga__Tblocking_errorES is string (1 .. 25);
   disk__fpga__blocking_errorE : constant string (1 .. 25) :=
     "DISK.FPGA.BLOCKING_ERROR["00"]";
   disk__fpga__R2s : constant access_character := access_character!(
     disk__fpga__blocking_errorE'address);
   disk__fpga__blocking_error : exception;
   system__exception_table__register_exception (
     system__standard_library__exception_data_ptr!(
     disk__fpga__blocking_error'unrestricted_access));
</pre>

</div>

That’s all exceptions seem to be under the hood.

# Records, Arrays and Discreet Types

Records are represented very efficiently. I see no overhead, and they seem to work just like C style structures.

The same holds true for arrays and and floating and integer types.

# Enumeration Types

Enumeration types are surprisingly efficient. Basically whenever you declare an enumeration:

<div class="codehilite">

<pre><span></span><span class="kd">type</span> <span class="kt">myenum</span> <span class="kr">is</span> <span class="p">(</span><span class="nv">somevalue</span><span class="p">,</span> <span class="nv">othervalue</span><span class="p">);</span>
</pre>

</div>

It’s turned into:

<div class="codehilite">

<pre><span></span><span class="kd">type</span> <span class="kt">myenum</span> <span class="kr">is</span> <span class="p">(</span><span class="nv">somevalue</span><span class="p">,</span> <span class="nv">othervalue</span><span class="p">);</span>
<span class="no">myenumS</span> <span class="p">:</span> <span class="kr">constant</span> <span class="kt">string</span> <span class="p">(</span><span class="mi">1</span> <span class="p">..</span> <span class="mi">19</span><span class="p">)</span> <span class="p">:=</span> <span class="s">"SOMEVALUEOTHERVALUE"</span><span class="p">;</span>
<span class="no">myenumI</span> <span class="p">:</span> <span class="kr">constant</span> <span class="kr">array</span> <span class="p">(</span><span class="mi">0</span> <span class="p">..</span> <span class="mi">2</span><span class="p">)</span> <span class="kr">of</span> <span class="n">integer_8</span> <span class="p">:=</span> <span class="p">(</span><span class="mi">1</span><span class="p">,</span> <span class="mi">10</span><span class="p">,</span> <span class="mi">20</span><span class="p">);</span>
</pre>

</div>

So it’s quite easy to figure out the string or integer value of an enumeration type.

# Initialization of Types

It seems that a decent sized chunk of code is generated every time we have a record type with a default value in there, e.g.

<div class="codehilite">

<pre><span></span>    <span class="kd">type</span> <span class="kt">my_record</span> <span class="kr">is</span> <span class="kr">record</span>
        <span class="n">something</span> <span class="p">:</span> <span class="n">some_type</span> <span class="p">:=</span> <span class="n">some_value</span><span class="p">;</span>
    <span class="kr">end record</span><span class="p">;</span>
</pre>

</div>

Ada will generate code wherever this type is declared, and also any time this record is part of another record, the other record will have code generated as well.

<div class="codehilite">

<pre><span></span>    <span class="kd">type</span> <span class="kt">other_record</span> <span class="kr">is</span> <span class="kr">record</span>
        <span class="n">my_record_type</span> <span class="p">:</span> <span class="n">my_record</span><span class="p">;</span> <span class="c1">-- no default value</span>
    <span class="kr">end record</span><span class="p">;</span>
</pre>

</div>

Will still have code generated to initialize it. This will cause the overhead of two function calls. (1) To initialize ‘other_record’ which will (2) call the code to initialize ‘my_record’.

It’s especially bad in arrays, e.g.

<div class="codehilite">

<pre><span></span><span class="kd">type</span> <span class="kt">other_record_array</span> <span class="kr">is</span> <span class="p">(</span><span class="nv">integer</span> <span class="nv">range</span> <span class="p"><>)</span> <span class="kr">of</span> <span class="n">other_record</span><span class="p">;</span>
</pre>

</div>

will end up generating something like:

<div class="codehilite">

<pre><span></span><span class="kd">procedure</span> <span class="nf">initialize_other_array</span> <span class="p">(</span><span class="nv">x</span> <span class="p">:</span> <span class="nv">other_reccord_array</span><span class="p">)</span> <span class="kr">is</span>
<span class="kr">begin</span>
    <span class="kr">for</span> <span class="n">i</span> <span class="ow">in</span> <span class="n">x</span><span class="p">'</span><span class="na">range</span> <span class="kr">loop</span>
        <span class="kd">procedure</span><span class="nf">_to_initialize_other_record</span> <span class="p">(</span><span class="nv">x</span><span class="p">(</span><span class="nv">i</span><span class="p">));</span>
    <span class="kr">end</span> <span class="kr">loop</span><span class="p">;</span>
<span class="kr">end</span><span class="p">;</span>
</pre>

</div>

So we get Array’Length * 2 function calls in this case to create the array.

# Protected Types / Objects

These seem to be implemented in a pretty straight forward manner.

*   There is a mutex placed in the package
*   For all publically visibile procedures / functions, a N and P version are declared. The N is non protected version, and the P is the protected version.
*   For all private procedures / function, an N version is declared.

Let me illustrate:

<div class="codehilite">

<pre><span></span><span class="kd">package</span> <span class="nc">foo</span> <span class="kr">is</span>
    <span class="kd">protected</span> <span class="n">bar</span> <span class="kr">is</span>
        <span class="kd">function</span> <span class="nf">x</span> <span class="nf">return</span> <span class="nf">boolean</span><span class="p">;</span>
    <span class="kd">private</span>
        <span class="kd">function</span> <span class="nf">y</span> <span class="nf">return</span> <span class="nf">boolean</span><span class="p">;</span>
    <span class="kr">end</span> <span class="nf">bar</span><span class="p">;</span>
<span class="kr">end</span> <span class="nf">foo</span><span class="p">;</span>
</pre>

</div>

Gets turned into:

<div class="codehilite">

<pre><span></span><span class="kd">package</span> <span class="nc">foo</span> <span class="kr">is</span>
    <span class="kd">protected</span> <span class="kd">type</span> <span class="kt">barT</span> <span class="kr">is</span>
        <span class="kd">function</span> <span class="nf">x</span> <span class="nf">return</span> <span class="nf">boolean</span><span class="p">;</span>
    <span class="kd">private</span>
        <span class="kd">function</span> <span class="nf">y</span> <span class="nf">return</span> <span class="nf">boolean</span><span class="p">;</span>
    <span class="kr">end</span> <span class="nf">bar</span><span class="p">;</span>

    <span class="n">bar</span> <span class="p">:</span> <span class="n">barT</span><span class="p">;</span>

    <span class="kd">type</span> <span class="kt">foo__barTV</span> <span class="kr">is</span> <span class="kr">limited</span> <span class="kr">record</span>
        <span class="mi">_</span><span class="n">object</span> <span class="p">:</span> <span class="kr">aliased</span>
            <span class="n">system__tasking__protected_objects__protection</span><span class="p">;</span>
    <span class="kr">end record</span><span class="p">;</span>

    <span class="c1">-- Code to initialize barT, which will set up its priority</span>
    <span class="c1">-- and initialize foo__barTV.  I don't know where an instance</span>
    <span class="c1">-- of the  object foo__barTV is actually declared.</span>

    <span class="kd">function</span> <span class="nf">foo__barT__xN</span><span class="p">(</span><span class="nv">_object</span> <span class="p">:</span> <span class="nv">in</span> <span class="nv">out</span>  <span class="nv">foo__barTV</span><span class="p">)</span>
        <span class="kr">return</span> <span class="kt">boolean</span><span class="p">;</span>
    <span class="kd">function</span> <span class="nf">foo__barT__xP</span><span class="p">(</span><span class="nv">_object</span> <span class="p">:</span> <span class="nv">in</span> <span class="nv">out</span>  <span class="nv">foo__barTV</span><span class="p">)</span>
        <span class="kr">return</span> <span class="kt">boolean</span><span class="p">;</span>

    <span class="kd">function</span> <span class="nf">foo__barT__yN</span><span class="p">(</span><span class="nv">_object</span> <span class="p">:</span> <span class="nv">in</span> <span class="nv">out</span>  <span class="nv">foo__barTV</span><span class="p">)</span>
        <span class="kr">return</span> <span class="kt">boolean</span><span class="p">;</span>

<span class="kr">end</span> <span class="nf">foo</span><span class="p">;</span>
</pre>

</div>

# Overhead with Protected Types

As we’ve seen, there is a P (protected) version of all functions and procedures declared. Here is what the body of a null procedure (body is just ‘null’) is expanded to:

NOTE: The procedure was called ‘p’, and it was in a procedure called test that declared a type test_type.

<div class="codehilite">

<pre><span></span><span class="kd">procedure</span> <span class="nf">test__test_typePT__pP</span> <span class="p">(</span><span class="nv">_object</span> <span class="p">:</span> <span class="nv">in</span> <span class="nv">out</span> <span class="nv">test__test_typeTV</span><span class="p">)</span> <span class="kr">is</span>
   <span class="kd">procedure</span> <span class="nf">test__test_typePT__pP___clean</span> <span class="kr">is</span>
   <span class="kr">begin</span>
      <span class="n">system__tasking__protected_objects__unlock</span> <span class="p">(</span><span class="mi">_</span><span class="n">object</span><span class="p">.</span><span class="mi">_</span><span class="n">object</span><span class="p">'</span>
        <span class="n">unchecked_access</span><span class="p">);</span>
      <span class="n">system__soft_links__abort_undefer</span><span class="p">.</span><span class="kr">all</span><span class="p">;</span>
      <span class="kr">return</span><span class="p">;</span>
   <span class="kr">end</span> <span class="nf">test__test_typePT__pP___clean</span><span class="p">;</span>
<span class="kr">begin</span>
   <span class="n">system__soft_links__abort_defer</span><span class="p">.</span><span class="kr">all</span><span class="p">;</span>
   <span class="n">system__tasking__protected_objects__lock</span> <span class="p">(</span><span class="mi">_</span><span class="n">object</span><span class="p">.</span><span class="mi">_</span><span class="n">object</span><span class="p">'</span>
     <span class="n">unchecked_access</span><span class="p">);</span>
   <span class="nl">B3b</span> <span class="p">:</span> <span class="kr">begin</span>
      <span class="n">test__test_typePT__pN</span> <span class="p">(</span><span class="mi">_</span><span class="n">object</span><span class="p">);</span>
   <span class="kr">exception</span>
      <span class="kr">when</span> <span class="kr">all</span> <span class="kr">others</span> <span class="p">=></span>
         <span class="nl">B6b</span> <span class="p">:</span> <span class="kr">declare</span>
            <span class="n">E5b</span> <span class="p">:</span> <span class="n">ada__exceptions__exception_occurrence</span><span class="p">;</span>
         <span class="kr">begin</span>
            <span class="n">ada__exceptions__save_occurrence</span> <span class="p">(</span><span class="n">E5b</span><span class="p">,</span>
              <span class="n">system__soft_links__get_current_excep</span><span class="p">.</span><span class="kr">all</span><span class="p">.</span><span class="kr">all</span><span class="p">);</span>
            <span class="n">test__test_typePT__pP___clean</span><span class="p">;</span>
            <span class="n">ada__exceptions__reraise_occurrence_no_defer</span> <span class="p">(</span><span class="n">E5b</span><span class="p">);</span>
         <span class="kr">end</span> <span class="nf">B6b</span><span class="p">;</span>
   <span class="kr">at</span> <span class="kr">end</span>
      <span class="nf">test__test_typePT__pP___clean</span><span class="p">;</span>
   <span class="kr">end</span> <span class="nf">B3b</span><span class="p">;</span>
   <span class="kr">return</span><span class="p">;</span>
<span class="kr">end</span> <span class="nf">test__test_typePT__pP</span><span class="p">;</span>
</pre>

</div>

It seems that we should keep our protected types as small as possible. This means (1) only using protected types when necessary and (2) keeping the public interface to a protected type as small as possible.

Something strange happens as soon as an entry is added to a protected type. A bunch of code is added that (1) adds a queue per entry, on which tasks will wait to enter the protected type until the entry condition is true (2) and finalization code to clean up after these queues.

There is a notable difference between protected types with no entries, and those with.

# Tasks

Tasks are not lightweight objects. The following components add up rather quickly:

*   Code to initialize a task.
*   Code to clean up after a task.
*   Handling exceptions during

If you want to look at the code generated for a task, try compiling the following:

<div class="codehilite">

<pre><span></span><span class="kd">procedure</span> <span class="nf">test</span> <span class="kr">is</span>
    <span class="kd">task</span> <span class="n">test_task</span> <span class="kr">is</span>
        <span class="kd">entry</span> <span class="nf">Start</span><span class="p">;</span>
    <span class="kr">end</span> <span class="nf">test_task</span><span class="p">;</span>
    <span class="kd">task</span> <span class="kr">body</span> <span class="n">test_task</span> <span class="kr">is</span>
    <span class="kr">begin</span>
        <span class="kr">accept</span> <span class="n">Start</span><span class="p">;</span>
        <span class="kr">loop</span>
            <span class="kr">delay</span> <span class="mf">1.0</span><span class="p">;</span>
        <span class="kr">end</span> <span class="kr">loop</span><span class="p">;</span>
    <span class="kr">end</span> <span class="nf">test_task</span><span class="p">;</span>
<span class="kr">begin</span>
    <span class="n">test_task</span><span class="p">.</span><span class="n">start</span><span class="p">;</span>
<span class="kr">end</span> <span class="nf">test</span><span class="p">;</span>
</pre>

</div>

The processed source is 4055 bytes and 117 lines. You can view the code in the appendix.

# Subtypes and Renaming

Subtypes and package / procedure renaming is done in a sane manner. Subtypes are just subtypes, nothing extra is generated, and neither is anything done for renaming.

# Overhead with T’Image / Value’Img and Put_Line

So far, I’ve only found the following to happen when using T’Image for some type T, and Value’Image, for some variable or constant Value.

Here is the typical code (in a procedure called ‘test’):

<div class="codehilite">

<pre><span></span><span class="kd">procedure</span> <span class="nf">test1</span> <span class="kr">is</span>
    <span class="no">t1</span> <span class="p">:</span> <span class="kr">constant</span> <span class="kt">integer</span> <span class="p">:=</span> <span class="mi">1</span><span class="p">;</span>
<span class="kr">begin</span>
    <span class="n">ada</span><span class="p">.</span><span class="n">text_io</span><span class="p">.</span><span class="n">put_line</span><span class="p">(</span><span class="n">t1</span><span class="p">'</span><span class="na">img</span><span class="p">);</span>
<span class="kr">end</span> <span class="nf">test1</span><span class="p">;</span>
</pre>

</div>

For some reason, GNAT is turning this into the following horrific procedure:

<div class="codehilite">

<pre><span></span><span class="kd">procedure</span> <span class="nf">test__test1</span> <span class="kr">is</span>
   <span class="n">M5b</span> <span class="p">:</span> <span class="n">system__secondary_stack__mark_id</span> <span class="p">:=</span>
     <span class="n">system__secondary_stack__ss_mark</span><span class="p">;</span>

   <span class="kd">procedure</span> <span class="nf">test__test1___clean</span> <span class="kr">is</span>
   <span class="kr">begin</span>
      <span class="n">system__secondary_stack__ss_release</span> <span class="p">(</span><span class="n">M5b</span><span class="p">);</span>
      <span class="kr">return</span><span class="p">;</span>
   <span class="kr">end</span> <span class="nf">test__test1___clean</span><span class="p">;</span>
<span class="kr">begin</span>
   <span class="no">t1</span> <span class="p">:</span> <span class="kr">constant</span> <span class="kt">integer</span> <span class="p">:=</span> <span class="mi">1</span><span class="p">;</span>
   <span class="nl">B4b</span> <span class="p">:</span> <span class="kr">declare</span>
   <span class="kr">begin</span>
      <span class="n">ada</span><span class="p">.</span><span class="n">ada__text_io</span><span class="p">.</span><span class="n">ada__text_io__put_line</span> <span class="p">(</span>
        <span class="n">system__img_int__image_integer</span> <span class="p">(</span><span class="n">t1</span><span class="p">));</span>
   <span class="kr">end</span> <span class="nf">B4b</span><span class="p">;</span>
   <span class="kr">return</span><span class="p">;</span>
<span class="kr">exception</span>
   <span class="kr">when</span> <span class="kr">all</span> <span class="kr">others</span> <span class="p">=></span>
      <span class="nl">B7b</span> <span class="p">:</span> <span class="kr">declare</span>
         <span class="n">E6b</span> <span class="p">:</span> <span class="n">ada__exceptions__exception_occurrence</span><span class="p">;</span>
      <span class="kr">begin</span>
         <span class="n">ada__exceptions__save_occurrence</span> <span class="p">(</span><span class="n">E6b</span><span class="p">,</span>
           <span class="n">system__soft_links__get_current_excep</span><span class="p">.</span><span class="kr">all</span><span class="p">.</span><span class="kr">all</span><span class="p">);</span>
         <span class="n">test__test1___clean</span><span class="p">;</span>
         <span class="n">ada__exceptions__reraise_occurrence_no_defer</span> <span class="p">(</span><span class="n">E6b</span><span class="p">);</span>
      <span class="kr">end</span> <span class="nf">B7b</span><span class="p">;</span>
      <span class="kr">return</span><span class="p">;</span>
<span class="kr">at</span> <span class="kr">end</span>
   <span class="nf">test__test1___clean</span><span class="p">;</span>
<span class="kr">end</span> <span class="nf">test__test1</span><span class="p">;</span>
</pre>

</div>

I have looked at other places where exceptions are raised, and haven’t found the above. I don’t understand the reason for why the above is happening. It’s especially bad if a small function calls ‘Image or ‘Img. It seems that much larger functions, or functions that make liberal use of T’Image or Value’Img, would be able to make up for the cost of all this junk by doing enough work.

Some things worth noting:

*   Putting a To_String (Value : T) return String function in a package to convert the type to a string doesn’t seem to do the trick. We still end up with all this exception junk, and the secondary stack the caller.
*   Putting an entire Put (Value : T) in another package does seem to work.
*   _Each block_ that has a T’Img seems to get all the junk. This is especially bad if there are many small functions or small blocks that call the ‘Img.
*   _Each for loop_ is equivalent to a block, in the sense that a begin and end is generated for each for loop and all this junk is put in that block. Many places have an outside for loop that has an inner block, that again has a for loop. This adds up to at least three blocks that have all this junk associated with them. The inner blocks are allocated upon each iteration of the loop.

# Appendix

Code generated for the dummy task.

<div class="codehilite">

<pre><span></span><span class="kn">with</span> <span class="nn">system.system__parameters</span><span class="p">;</span>
<span class="kn">with</span> <span class="nn">system.system__tasking</span><span class="p">;</span>
<span class="kn">with</span> <span class="nn">system.system__task_info</span><span class="p">;</span>
<span class="kn">with</span> <span class="nn">system.system__tasking.system__tasking__stages</span><span class="p">;</span>
<span class="kn">with</span> <span class="nn">system</span><span class="p">;</span>
<span class="kn">with</span> <span class="nn">system.system__soft_links</span><span class="p">;</span>
<span class="kn">with</span> <span class="nn">system.system__tasking.system__tasking__rendezvous</span><span class="p">;</span>
<span class="kn">with</span> <span class="nn">ada.ada__calendar.ada__calendar__delays</span><span class="p">;</span>
<span class="kn">with</span> <span class="nn">ada.ada__exceptions</span><span class="p">;</span>

<span class="kd">procedure</span> <span class="nf">test</span> <span class="kr">is</span>

   <span class="kd">procedure</span> <span class="nf">test___clean</span> <span class="kr">is</span>
   <span class="kr">begin</span>
      <span class="n">system__soft_links__abort_defer</span><span class="p">.</span><span class="kr">all</span><span class="p">;</span>
      <span class="n">system__soft_links__complete_master</span><span class="p">.</span><span class="kr">all</span><span class="p">;</span>
      <span class="n">system__soft_links__abort_undefer</span><span class="p">.</span><span class="kr">all</span><span class="p">;</span>
      <span class="kr">return</span><span class="p">;</span>
   <span class="kr">end</span> <span class="nf">test___clean</span><span class="p">;</span>
<span class="kr">begin</span>
   <span class="n">system__soft_links__enter_master</span><span class="p">.</span><span class="kr">all</span><span class="p">;</span>
   <span class="mi">_</span><span class="n">chain</span> <span class="p">:</span> <span class="kr">aliased</span> <span class="n">system__tasking__activation_chain</span><span class="p">;</span>
   <span class="n">system__tasking___init_proc</span> <span class="p">(</span><span class="mi">_</span><span class="n">chain</span><span class="p">);</span>
   <span class="kd">task</span> <span class="kd">type</span> <span class="kt">test__test_taskTK</span> <span class="kr">is</span>
      <span class="kd">entry</span> <span class="nf">start</span><span class="p">;</span>
   <span class="kr">end</span> <span class="nf">test__test_taskTK</span><span class="p">;</span>
   <span class="n">test_taskTKE</span> <span class="p">:</span> <span class="kr">aliased</span> <span class="kt">boolean</span> <span class="p">:=</span> <span class="kc">false</span><span class="p">;</span>
   <span class="n">test_taskTKZ</span> <span class="p">:</span> <span class="n">system__parameters__size_type</span> <span class="p">:=</span>
     <span class="n">system__parameters__unspecified_size</span><span class="p">;</span>
   <span class="kd">type</span> <span class="kt">test__test_taskTKV</span> <span class="kr">is</span> <span class="kr">limited</span> <span class="kr">record</span>
      <span class="mi">_</span><span class="kd">task</span><span class="mi">_</span><span class="n">id</span> <span class="p">:</span> <span class="n">system__tasking__task_id</span><span class="p">;</span>
   <span class="kr">end record</span><span class="p">;</span>
   <span class="kd">procedure</span> <span class="nf">test__test_taskTKB</span> <span class="p">(</span><span class="nv">_task</span> <span class="p">:</span> <span class="nv">access</span> <span class="nv">test__test_taskTKV</span><span class="p">);</span>
   <span class="n">freeze</span> <span class="n">test__test_taskTKV</span> <span class="err">[</span>
      <span class="kd">procedure</span> <span class="nf">test___init_proc</span> <span class="p">(</span><span class="nv">_init</span> <span class="p">:</span> <span class="nv">in</span> <span class="nv">out</span> <span class="nv">test__test_taskTKV</span><span class="p">;</span>
        <span class="nv">_master</span> <span class="p">:</span> <span class="nv">system__tasking__master_id</span><span class="p">;</span> <span class="nv">_chain</span> <span class="p">:</span> <span class="nv">in</span> <span class="nv">out</span>
        <span class="nv">system__tasking__activation_chain</span><span class="p">;</span> <span class="nv">_task_id</span> <span class="p">:</span> <span class="nv">in</span>
        <span class="nv">system__task_info__task_image_type</span><span class="p">)</span> <span class="kr">is</span>
      <span class="kr">begin</span>
         <span class="mi">_</span><span class="n">init</span><span class="p">.</span><span class="mi">_</span><span class="kd">task</span><span class="mi">_</span><span class="n">id</span> <span class="p">:=</span> <span class="kc">null</span><span class="p">;</span>
         <span class="n">system__tasking__stages__create_task</span> <span class="p">(</span>
           <span class="n">system__tasking__unspecified_priority</span><span class="p">,</span> <span class="n">test_taskTKZ</span><span class="p">,</span>
           <span class="n">system__task_info__unspecified_task_info</span><span class="p">,</span> <span class="mi">1</span><span class="p">,</span> <span class="mi">_</span><span class="n">master</span><span class="p">,</span>
           <span class="n">system__tasking__task_procedure_access</span><span class="err">!</span><span class="p">(</span><span class="n">test__test_taskTKB</span><span class="p">'</span>
           <span class="kt">address</span><span class="p">),</span> <span class="mi">_</span><span class="n">init</span><span class="p">'</span><span class="na">address</span><span class="p">,</span> <span class="n">test_taskTKE</span><span class="p">'</span><span class="na">unchecked_access</span><span class="p">,</span>
           <span class="mi">_</span><span class="n">chain</span><span class="p">,</span> <span class="mi">_</span><span class="kd">task</span><span class="mi">_</span><span class="n">id</span><span class="p">,</span> <span class="mi">_</span><span class="n">init</span><span class="p">.</span><span class="mi">_</span><span class="kd">task</span><span class="mi">_</span><span class="n">id</span><span class="p">);</span>
         <span class="kr">return</span><span class="p">;</span>
      <span class="kr">end</span> <span class="nf">test___init_proc</span><span class="p">;</span>
   <span class="err">]</span>
   <span class="no">_master</span> <span class="p">:</span> <span class="kr">constant</span> <span class="n">system__tasking__master_id</span> <span class="p">:=</span>
     <span class="n">system__soft_links__current_master</span><span class="p">.</span><span class="kr">all</span><span class="p">;</span>
   <span class="n">test_task</span> <span class="p">:</span> <span class="n">test__test_taskTK</span><span class="p">;</span>
   <span class="n">test_taskI</span> <span class="p">:</span> <span class="n">system__task_info__task_image_type</span> <span class="p">:=</span> <span class="kr">new</span> <span class="kt">string</span><span class="p">'</span><span class="s">"test_task"</span><span class="p">;</span>
   <span class="n">test___init_proc</span> <span class="p">(</span><span class="n">test__test_taskTKV</span><span class="err">!</span><span class="p">(</span><span class="n">test_task</span><span class="p">),</span> <span class="mi">_</span><span class="n">master</span><span class="p">,</span> <span class="mi">_</span><span class="n">chain</span><span class="p">,</span>
     <span class="n">test_taskI</span><span class="p">);</span>

   <span class="kd">procedure</span> <span class="nf">test__test_taskTKB</span> <span class="p">(</span><span class="nv">_task</span> <span class="p">:</span> <span class="nv">access</span> <span class="nv">test__test_taskTKV</span><span class="p">)</span> <span class="kr">is</span>

      <span class="kd">procedure</span> <span class="nf">test__test_taskTK___clean</span> <span class="kr">is</span>
      <span class="kr">begin</span>
         <span class="n">system__soft_links__abort_defer</span><span class="p">.</span><span class="kr">all</span><span class="p">;</span>
         <span class="n">system__tasking__stages__complete_task</span><span class="p">;</span>
         <span class="n">system__soft_links__abort_undefer</span><span class="p">.</span><span class="kr">all</span><span class="p">;</span>
         <span class="kr">return</span><span class="p">;</span>
      <span class="kr">end</span> <span class="nf">test__test_taskTK___clean</span><span class="p">;</span>
   <span class="kr">begin</span>
      <span class="n">system__soft_links__abort_undefer</span><span class="p">.</span><span class="kr">all</span><span class="p">;</span>
      <span class="n">L_1</span> <span class="p">:</span> <span class="n">label</span>
      <span class="n">system__tasking__stages__complete_activation</span><span class="p">;</span>
      <span class="n">system__tasking__rendezvous__accept_trivial</span> <span class="p">(</span><span class="mi">1</span><span class="p">);</span>
      <span class="nl">L_1</span> <span class="p">:</span> <span class="kr">loop</span>
         <span class="n">ada__calendar__delays__delay_for</span> <span class="p">(</span><span class="mf">100000000.0</span><span class="n">E</span><span class="o">-</span><span class="mi">8</span><span class="p">);</span>
      <span class="kr">end</span> <span class="kr">loop</span> <span class="nf">L_1</span><span class="p">;</span>
      <span class="kr">return</span><span class="p">;</span>
   <span class="kr">exception</span>
      <span class="kr">when</span> <span class="kr">all</span> <span class="kr">others</span> <span class="p">=></span>
         <span class="nl">B7b</span> <span class="p">:</span> <span class="kr">declare</span>
            <span class="n">E6b</span> <span class="p">:</span> <span class="n">ada__exceptions__exception_occurrence</span><span class="p">;</span>
         <span class="kr">begin</span>
            <span class="n">ada__exceptions__save_occurrence</span> <span class="p">(</span><span class="n">E6b</span><span class="p">,</span>
              <span class="n">system__soft_links__get_current_excep</span><span class="p">.</span><span class="kr">all</span><span class="p">.</span><span class="kr">all</span><span class="p">);</span>
            <span class="n">test__test_taskTK___clean</span><span class="p">;</span>
            <span class="n">ada__exceptions__reraise_occurrence_no_defer</span> <span class="p">(</span><span class="n">E6b</span><span class="p">);</span>
         <span class="kr">end</span> <span class="nf">B7b</span><span class="p">;</span>
         <span class="kr">return</span><span class="p">;</span>
   <span class="kr">at</span> <span class="kr">end</span>
      <span class="nf">test__test_taskTK___clean</span><span class="p">;</span>
   <span class="kr">end</span> <span class="nf">test__test_taskTKB</span><span class="p">;</span>

   <span class="n">test_taskTKE</span> <span class="p">:=</span> <span class="kc">true</span><span class="p">;</span>
   <span class="n">system__tasking__stages__activate_tasks</span> <span class="p">(</span><span class="mi">_</span><span class="n">chain</span><span class="p">'</span><span class="na">unchecked_access</span><span class="p">);</span>
   <span class="nl">B9b</span> <span class="p">:</span> <span class="kr">declare</span>
      <span class="n">X</span> <span class="p">:</span> <span class="n">system__tasking__task_entry_index</span> <span class="p">:=</span> <span class="mi">1</span><span class="p">;</span>
   <span class="kr">begin</span>
      <span class="n">system__tasking__rendezvous__call_simple</span> <span class="p">(</span><span class="n">test__test_taskTKV</span><span class="err">!</span><span class="p">(</span>
        <span class="n">test_task</span><span class="p">).</span><span class="mi">_</span><span class="kd">task</span><span class="mi">_</span><span class="n">id</span><span class="p">,</span> <span class="n">X</span><span class="p">,</span> <span class="n">system__null_address</span><span class="p">);</span>
   <span class="kr">end</span> <span class="nf">B9b</span><span class="p">;</span>
   <span class="kr">return</span><span class="p">;</span>
<span class="kr">exception</span>
   <span class="kr">when</span> <span class="kr">all</span> <span class="kr">others</span> <span class="p">=></span>
      <span class="nl">B12b</span> <span class="p">:</span> <span class="kr">declare</span>
         <span class="n">E11b</span> <span class="p">:</span> <span class="n">ada__exceptions__exception_occurrence</span><span class="p">;</span>
      <span class="kr">begin</span>
         <span class="n">ada__exceptions__save_occurrence</span> <span class="p">(</span><span class="n">E11b</span><span class="p">,</span>
           <span class="n">system__soft_links__get_current_excep</span><span class="p">.</span><span class="kr">all</span><span class="p">.</span><span class="kr">all</span><span class="p">);</span>
         <span class="n">test___clean</span><span class="p">;</span>
         <span class="n">ada__exceptions__reraise_occurrence_no_defer</span> <span class="p">(</span><span class="n">E11b</span><span class="p">);</span>
      <span class="kr">end</span> <span class="nf">B12b</span><span class="p">;</span>
      <span class="kr">return</span><span class="p">;</span>
<span class="kr">at</span> <span class="kr">end</span>
   <span class="nf">test___clean</span><span class="p">;</span>
<span class="kr">end</span> <span class="nf">test</span><span class="p">;</span>
</pre>

</div>