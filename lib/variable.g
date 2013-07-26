#############################################################################
##
#W  variable.g                  GAP library                      Frank Celler
##
##
#Y  Copyright (C)  1997,  Lehrstuhl D für Mathematik,  RWTH Aachen,  Germany
#Y  (C) 1998 School Math and Comp. Sci., University of St Andrews, Scotland
#Y  Copyright (C) 2002 The GAP Group
##
##  This file contains the functions for the special handling of those global
##  variables in {\GAP} library files that are *not* functions;
##  they are declared with `DeclareGlobalVariable' and initialized with
##  `InstallValue' resp.~`InstallFlushableValue'.
##
##  For the global functions in the {\GAP} libraray, see `oper.g'.
##


#############################################################################
##

#C  IsToBeDefinedObj. . . . . . . .  represenation of "to be defined" objects
##
DeclareCategory( "IsToBeDefinedObj", IsObject );


#############################################################################
##
#V  ToBeDefinedObjFamily  . . . . . . . . . family of "to be defined" objects
##
BIND_GLOBAL( "ToBeDefinedObjFamily",
    NewFamily( "ToBeDefinedObjFamily", IsToBeDefinedObj ) );


#############################################################################
##
#V  ToBeDefinedObjType  . . . . . . . . . . . type of "to be defined" objects
##
BIND_GLOBAL( "ToBeDefinedObjType", NewType(
    ToBeDefinedObjFamily, IsPositionalObjectRep ) );


#############################################################################
##
#F  NewToBeDefinedObj() . . . . . . . . . create a new "to be defined" object
##
BIND_GLOBAL( "NewToBeDefinedObj",
    name -> Objectify( ToBeDefinedObjType, [ name ] ) );


#############################################################################
##
#M  PrintObj( <obj> ) . . . . . . . . . . . . .  print "to be defined" object
##
InstallMethod( PrintObj,
    "for 'to be defined' objects",
    [ IsToBeDefinedObj ],
function(obj)
    Print( "<< ",obj![1]," to be defined>>" );
end );


#############################################################################
##
#O  FlushCaches( ) . . . . . . . . . . . . . . . . . . . . . Clear all caches
##
##  <#GAPDoc Label="FlushCaches">
##  <ManSection>
##  <Oper Name="FlushCaches" Arg=""/>
##
##  <Description>
##  <Ref Func="FlushCaches"/> resets the value of each global variable that
##  has been declared with <Ref Func="DeclareGlobalVariable"/> and for which
##  the initial value has been set with <Ref Func="InstallFlushableValue"/>
##  to this initial value.
##  <P/>
##  <Ref Func="FlushCaches"/> should be used only for debugging purposes,
##  since the involved global variables include for example lists that store
##  finite fields and cyclotomic fields used in the current &GAP; session,
##  in order to avoid that these fields are constructed anew in each call
##  to <Ref Func="GF" Label="for field size"/> and
##  <Ref Func="CF" Label="for (subfield and) conductor"/>.
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
DeclareOperation( "FlushCaches", [] );
# This method is just that one method is callable. It is installed first, so
# it will be last in line.
InstallMethod( FlushCaches, "return method", [], function() end );


#############################################################################
##
#F  DeclareGlobalVariable( <name>[, <description>] )
##
##  <#GAPDoc Label="DeclareGlobalVariable">
##  <ManSection>
##  <Func Name="DeclareGlobalVariable" Arg="name[, description]"/>
##
##  <Description>
##  For global variables that are <E>not</E> functions,
##  instead of using <Ref Func="BindGlobal"/> one can also declare the
##  variable with <Ref Func="DeclareGlobalVariable"/>
##  which creates a new global variable named by the string <A>name</A>.
##  If the second argument <A>description</A> is entered then this must be
##  a string that describes the meaning of the global variable.
##  <Ref Func="DeclareGlobalVariable"/> shall be used in the declaration part
##  of the respective package
##  (see&nbsp;<Ref Sect="Declaration and Implementation Part"/>),
##  values can then be assigned to the new variable with
##  <Ref Func="InstallValue"/> or <Ref Func="InstallFlushableValue"/>,
##  in the implementation part
##  (again, see&nbsp;<Ref Sect="Declaration and Implementation Part"/>).
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
BIND_GLOBAL( "DeclareGlobalVariable", function( arg )
    BIND_GLOBAL( arg[1], NewToBeDefinedObj(arg[1]) );
end );


#############################################################################
##
#F  InstallValue( <gvar>, <value> )
#F  InstallFlushableValue( <gvar>, <value> )
##
##  <#GAPDoc Label="InstallValue">
##  <ManSection>
##  <Func Name="InstallValue" Arg="gvar, value"/>
##  <Func Name="InstallFlushableValue" Arg="gvar, value"/>
##
##  <Description>
##  <Ref Func="InstallValue"/> assigns the value <A>value</A> to the global
##  variable <A>gvar</A>.
##  <Ref Func="InstallFlushableValue"/> does the same but additionally
##  provides that each call of <Ref Func="FlushCaches"/>
##  will assign a structural copy of <A>value</A> to <A>gvar</A>.
##  <P/>
##  <Ref Func="InstallValue"/> does <E>not</E> work if <A>value</A> is an
##  <Q>immediate object</Q>, i.e., an internally represented small integer or
##  finite field element.
##  Furthermore, <Ref Func="InstallFlushableValue"/> works only if
##  <A>value</A> is a list or a record.
##  (Note that <Ref Func="InstallFlushableValue"/> makes sense only for
##  <E>mutable</E> global variables.)
##  </Description>
##  </ManSection>
##  <#/GAPDoc>
##
##  Using `DeclareGlobalVariable' and `InstallFlushableValue' has several
##  advantages, compared to simple assignments.
##  1. The initial value must be written down only once in the file;
##     this is an argument in particular for the variable `Primes2'.
##  2. The implementation of `FlushCaches' is not prescribed,
##     at least it is hidden in the function `InstallFlushableValue'.
##  3. It is possible to access the `#V' global variables from within GAP,
##     perhaps separately for each package.
##     Note that the assignments of other global variables via
##     `DeclareOperation', `DeclareProperty' etc. would admit this already.
##

BIND_GLOBAL( "FLUSHABLE_VALUE_REGION", NewRegion("FLUSHABLE_VALUE_REGION"));

BIND_GLOBAL( "InstallValue", function ( gvar, value )
    local tmp;
    if (not IsBound(REREADING) or REREADING = false) and not
       IsToBeDefinedObj( gvar ) then
        Error("InstallValue: a value has been installed already");
    fi;
    if IsFamily( value ) then
      INFO_DEBUG( 1,
          "please use `BindGlobal' for the family object ",
          value!.NAME, ", not `InstallValue'" );
    fi;
    if IsPublic(value) then
      # TODO: We need to handle those cases more cleanly.
      if IS_ATOMIC_RECORD(value) then
        value := AtomicRecord(FromAtomicRecord(value));
      elif IS_ATOMIC_LIST(value) then
        value := AtomicList(FromAtomicList(value));
      elif IS_FIXED_ATOMIC_LIST(value) then
        value := FixedAtomicList(FromAtomicList(value));
      else
        if IS_COMOBJ(value) then
	  # atomic component object
	  value := Objectify(TypeObj(value), FromAtomicComObj(value));
	elif IS_POSOBJ(value) then
	  # atomic positional object
	  CLONE_OBJ(gvar, value);
	  return;
	elif IS_MUTABLE_OBJ(value) then
	  value := ShallowCopy(value);
	else
	  value := MakeImmutable(ShallowCopy(value));
	fi;
      fi;
      FORCE_SWITCH_OBJ (gvar, value);
    elif IsType(value) and IsReadOnly(value) then
      value := CopyRegion(value);
      FORCE_SWITCH_OBJ(gvar, value);
      MakeReadOnlyObj(gvar);
    elif IsShared(value) then
      atomic value do
        tmp := CopyRegion(value);
	MigrateObj(tmp, value);
	FORCE_SWITCH_OBJ(gvar, tmp);
      od;
    else
      value := CopyRegion(value);
      FORCE_SWITCH_OBJ(gvar, value);
    fi;
end);


BIND_GLOBAL( "InstallFlushableValue", function( gvar, value )
    local initval;

    if not ( IS_LIST( value ) or IS_REC( value ) ) then
      Error( "InstallFlushableValue: <value> must be a list or a record" );
    fi;

    if IsPublic(value) then
      Error( "InstallFlushableValue: <value> must not be in the public region" );
    fi;


    # Make a structural copy of the initial value and put it in a shared
    # region.
    initval:= CopyRegion( value );
    LockAndMigrateObj(initval, FLUSHABLE_VALUE_REGION);

    # Initialize the variable.
    # InstallValue() will always make a copy of value, so we
    # can reuse it.
    InstallValue( gvar, value );

    # Install the method to flush the cache.
    InstallMethod( FlushCaches,
      [],
      function()
	  if HaveWriteAccess(gvar) then
	    atomic gvar, initval do
	      SWITCH_OBJ( gvar, MigrateObj(CopyRegion( initval ), gvar) );
	    od;
	  fi;
          TryNextMethod();
      end );
end );

##  Bind some keywords as global variables such that <Tab> completion works
##  for them. These variables are not accessible.
BIND_GLOBAL( "Unbind", 0 );
BIND_GLOBAL( "true", 0 );
BIND_GLOBAL( "false", 0 );
BIND_GLOBAL( "while", 0 );
BIND_GLOBAL( "repeat", 0 );
BIND_GLOBAL( "until", 0 );
#BIND_GLOBAL( "SaveWorkspace", 0 );
BIND_GLOBAL( "else", 0 );
BIND_GLOBAL( "elif", 0 );
BIND_GLOBAL( "function", 0 );
BIND_GLOBAL( "local", 0 );
BIND_GLOBAL( "return", 0 );
BIND_GLOBAL( "then", 0 );
BIND_GLOBAL( "quit", 0 );
BIND_GLOBAL( "break", 0 );
BIND_GLOBAL( "continue", 0 );
BIND_GLOBAL( "IsBound", 0 );
BIND_GLOBAL( "TryNextMethod", 0 );
BIND_GLOBAL( "Info", 0 );
BIND_GLOBAL( "Assert", 0 );

#
# Type for lvars bags
#

DeclareCategory("IsLVarsBag", IsObject);
BIND_GLOBAL( "LVARS_FAMILY", NewFamily(IsLVarsBag, IsLVarsBag));
BIND_GLOBAL( "TYPE_LVARS", NewType(LVARS_FAMILY, IsLVarsBag));

#############################################################################
#
# Namespaces:
#
BIND_GLOBAL( "NAMESPACES_STACK", ShareObj([]) );

BIND_GLOBAL( "ENTER_NAMESPACE",
  function( namesp )
    if not(IS_STRING_REP(namesp)) then
        Error( "<namesp> must be a string" );
        return;
    fi;
    namesp := MakeImmutable(CopyRegion(namesp));
    atomic NAMESPACES_STACK do
        NAMESPACES_STACK[LEN_LIST(NAMESPACES_STACK)+1] := namesp;
    od;
    SET_NAMESPACE(namesp);
  end );

BIND_GLOBAL( "LEAVE_NAMESPACE",
  function( )
    atomic NAMESPACES_STACK do
      if LEN_LIST(NAMESPACES_STACK) = 0 then
	  SET_NAMESPACE(MakeImmutable(""));
	  Error( "was not in any namespace" );
      else
	  UNB_LIST(NAMESPACES_STACK,LEN_LIST(NAMESPACES_STACK));
	  if LEN_LIST(NAMESPACES_STACK) = 0 then
	      SET_NAMESPACE(MakeImmutable(""));
	  else
	      SET_NAMESPACE(NAMESPACES_STACK[LEN_LIST(NAMESPACES_STACK)]);
	  fi;
      fi;
    od;
  end );

BIND_GLOBAL( "LEAVE_ALL_NAMESPACES",
  function( )
    local i;
    atomic NAMESPACES_STACK do
      SET_NAMESPACE(MakeImmutable(""));
      for i in [1..LEN_LIST(NAMESPACES_STACK)] do
	   UNB_LIST(NAMESPACES_STACK,i);
      od;
    od;
  end );
    
BIND_GLOBAL( "CURRENT_NAMESPACE",
  function()
    atomic NAMESPACES_STACK do
      if LEN_LIST(NAMESPACES_STACK) > 0 then
	  return NAMESPACES_STACK[LEN_LIST(NAMESPACES_STACK)];
      else
	  return "";
      fi;
    od;
  end );

#############################################################################
##

#E

