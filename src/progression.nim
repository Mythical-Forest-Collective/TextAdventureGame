# Copyright 2022 EHC + Ecorous
# 
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
# 
#     http://www.apache.org/licenses/LICENSE-2.0
# 
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Actually, what if there's a format?
# battle data would be empty 
# 
proc start(int stage = 0): # this seems wrong, like a crude goto impl, not sure exactly what to do otherwise. although its 2am for them
  if stage == 0:
    # 
    # do stuff for this stage
    #
    
    # Move on to next stage
    
    start(1)
  elif stage == 1:
    # 
    # do stuff for this stage
    #
    
    # Move on to next stage
    
    start(2)
  elif stage == 2:
    # 
    # do stuff for this stage
    #
    
    # Move on to next stage
    
    start(3)

