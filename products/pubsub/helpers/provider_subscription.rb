# Copyright 2017 Google Inc.
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

def decode_request(response)
  self.class.decode_request(response)
end

def self.decode_request(response)
  resp = JSON.parse(response.body)
  resp['name'] = resp['name'].split('/').last if resp['name']
  resp['topic'] = resp['topic'].split('/').last if resp['topic']
  resp
end
