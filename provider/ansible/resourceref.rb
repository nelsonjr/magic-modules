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

require 'api/object'
require 'compile/core'
require 'provider/config'
require 'provider/core'
require 'provider/ansible/manifest'

module Provider
  class Ansible
    module ResourceRef
      # Builds out a list of statements that handle ResourceRef creation
      def resourceref_handlers(object)
        rrefs = nonvirtual_rrefs(object)
        return unless rrefs.any?
        comments = [
         "# Converts data from:",
         "# foo:",
         "#   - self_link: 'sl1'",
         "#     name: 'name1'",
         "#",
         "# to",
         "# foo: 'sl1'"
        ]
        comments + rrefs.map { |rref| resourceref_handler(rref) }
      end

      def resourceref_handler(rref)
        rref_path = path_for_rref(rref)
        value_path = quote_string(Google::StringUtils.underscore(rref.imports))
        format([
          ["module.set_value_for_resource(#{rref_path}, #{value_path})"],

          [
            'module.set_value_for_resource(',
            indent("#{rref_path}, #{value_path}", 4),
            ')'
          ],
          [
            'module.set_value_for_resource(',
            indent_list([rref_path, value_path], 4),
            ')'
          ]
        ])
      end

      private

      def path_for_rref(rref)
        past_values = []
        while !rref.nil?
          past_values << Google::StringUtils.underscore(rref.name)
          # TODO(alexstephen): Investigate a better way to handle parent
          # pointers on Arrays of NestedObjects
          if rref.is_a?(Api::Type::NestedObject) && \
            rref.parent.is_a?(Api::Type::Array)
            rref = rref.parent.parent
          else
            rref = rref.parent
          end
        end
        "[#{past_values.reverse.map { |x| quote_string(x) }.join(', ')}]"
      end
    end
  end
end
