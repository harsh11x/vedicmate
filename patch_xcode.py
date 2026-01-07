import sys

msg_file_ref = '		A1B2C3D4E5F6789012345678 /* GoogleService-Info.plist */ = {isa = PBXFileReference; fileEncoding = 4; lastKnownFileType = text.plist.xml; path = "GoogleService-Info.plist"; sourceTree = "<group>"; };'
msg_build_file = '		B1C2D3E4F567890123456789 /* GoogleService-Info.plist in Resources */ = {isa = PBXBuildFile; fileRef = A1B2C3D4E5F6789012345678 /* GoogleService-Info.plist */; };'
msg_group_item = '				A1B2C3D4E5F6789012345678 /* GoogleService-Info.plist */,'
msg_resource_item = '				B1C2D3E4F567890123456789 /* GoogleService-Info.plist in Resources */,'

path = 'ios/Runner.xcodeproj/project.pbxproj'

with open(path, 'r') as f:
    lines = f.readlines()

new_lines = []
in_resources_phase = False
in_runner_group = False
resources_phase_id = '97C146EC1CF9000F007C117D'
runner_group_id = '97C146F01CF9000F007C117D'

# Check if already exists
content = ''.join(lines)
if 'GoogleService-Info.plist' in content:
    print("GoogleService-Info.plist already found in project.pbxproj")
    sys.exit(0)

for line in lines:
    new_lines.append(line)
    
    # 1. Insert Build File
    if '/* Begin PBXBuildFile section */' in line:
        new_lines.append(msg_build_file + '\n')

    # 2. Insert File Reference
    if '/* Begin PBXFileReference section */' in line:
        new_lines.append(msg_file_ref + '\n')

    # 3. Insert into Resources Build Phase
    if resources_phase_id in line and '/* Resources */' in line:
        in_resources_phase = True
    
    if in_resources_phase and 'files = (' in line:
        new_lines.append(msg_resource_item + '\n')
        in_resources_phase = False # Only insert once

    # 4. Insert into Runner Group
    if runner_group_id in line and '/* Runner */' in line:
        in_runner_group = True
    
    if in_runner_group and 'children = (' in line:
        new_lines.append(msg_group_item + '\n')
        in_runner_group = False # Only insert once

with open(path, 'w') as f:
    f.writelines(new_lines)

print("Successfully patched project.pbxproj")
