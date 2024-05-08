#!/usr/bin/env bash
# The MIT License (MIT)
#
# Copyright (c) 2021-2024 Yegor Bugayenko
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NON-INFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

# Test script for analyzing Java getter and setter methods and their complexities

set -e
set -o pipefail

# Setup temporary workspace
temp=$1
stdout=$2

# Location of the Python script
script_location="${LOCAL}/metrics/getset.py"

{
    # Create a simple Java file with getter and setter methods
    java_file="${temp}/Person.java"
    echo "public class Person {
        private String name;
        private int age;
        
        public String getName() {return this.name;}
        public void setName(String name) {this.name = name;}        
        public int getAge() {return this.age;}        
        public void setAge(int age) {this.age = age;}        
        public void nonAccessorMethod() {
            if (age > 18) {System.out.println(\"Adult\");}
        }
    }" > "${java_file}"
    
    metrics_file="${temp}/metrics.txt"
    "${script_location}" "${java_file}" "${metrics_file}"
    cat "${metrics_file}"
    
    # Assertions: Check for expected output related to getter, setter, and branches
    grep "Getters 2 The number of getter methods" "${metrics_file}"
    grep "Setters 2 The number of setter methods" "${metrics_file}"
} > "${stdout}" 2>&1

echo "👍 Correctly calculated Getter & Setter complexity"
