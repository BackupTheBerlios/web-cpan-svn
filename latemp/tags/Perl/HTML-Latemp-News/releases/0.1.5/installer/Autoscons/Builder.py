# Autoscons - An autotools replacement for SCons
# Copyright 2003 David Snopek
# 
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
# 
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
# 
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
# 

import os, types
import SCons.Action
import SCons.Builder
import Autoscons.Util

def GetPermissionVar(env):
	if not os.name in [ 'nt', 'posix' ]:
		return None
	try:
		perm = env['PERMISSION']
	except KeyError:
		perm = None
	return perm

def SetPermissionFunc(target, source, env):
	perm = GetPermissionVar(env)
	if perm != None:
		os.chmod(target[0].path, perm)

def SetPermissionString(target, source, env):
	perm = GetPermissionVar(env)
	if perm != None:
		return "chmod %o %s" % (perm, target[0])

SetPermissionAction = SCons.Action.Action(SetPermissionFunc, SetPermissionString, [ 'PERMISSION' ])

def GenericString(target, source, env):
	return "Creating: %s" % target[0]

def SymlinkFunc(target, source, env):
	s = Autoscons.Util.MakeRelativePath(source[0].path, os.path.dirname(target[0].path))
	d = target[0].path
	if os.path.isfile(d) or os.path.islink(d):
		os.unlink(d)
	os.symlink(s, d)

def SymlinkString(target, source, env):
	s = Autoscons.Util.MakeRelativePath(source[0].path, os.path.dirname(target[0].path))
	return "ln -sf %s %s" % (s, target[0])

SymlinkAction = SCons.Action.Action(SymlinkFunc, SymlinkString)
SymlinkBuilder = SCons.Builder.Builder(action = SymlinkAction)

def ExpandTemplateFunc(target, source, env):
	dec = env['DECODER']
	dec['target'] = target[0].name

	# works for either string or file!
	text = source[0].get_contents()

	fd = open(target[0].path, "wt")
	fd.write(text % dec)
	fd.close()

ExpandTemplateAction = SCons.Action.Action(ExpandTemplateFunc, GenericString, [ 'DECODER' ])
ExpandTemplateBuilder = SCons.Builder.Builder(action = [ ExpandTemplateAction, SetPermissionAction ])

def ConfigHeaderFunc(target, source, env):
	defines = source[0].value
	
	# lightly validate the object
	if type(defines) != types.ListType:
		raise SCons.Errors.UserError, \
			"The source must be a list of three item tuples!"
	
	fd = open(target[0].path, "wt")
	fd.write("/* Autogenerated by Autoscons! */\n\n")
	for def_name, val, desc in defines:
		if desc:
			# TODO: wrap desc to an 80 character screen
			fd.write("/* " + desc + " */\n")
		fd.write("#define " + def_name + " " + str(val) + "\n\n")
	fd.close()

ConfigHeaderAction = SCons.Action.Action(ConfigHeaderFunc, GenericString)
ConfigHeaderBuilder = SCons.Builder.Builder(action = ConfigHeaderAction)

def ExtendEnvironment(env):
	env['BUILDERS']['Symlink'] = SymlinkBuilder
	env['BUILDERS']['ExpandTemplate'] = ExpandTemplateBuilder
	env['BUILDERS']['ConfigHeader'] = ConfigHeaderBuilder


