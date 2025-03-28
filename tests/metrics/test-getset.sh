#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2021-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT

set -e -o pipefail

temp=$1
stdout=$2

script_location="${LOCAL}/metrics/getset.py"

{
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
    grep "Getters 2 The number of getter methods" "${metrics_file}"
    grep "Setters 2 The number of setter methods" "${metrics_file}"
} > "${stdout}" 2>&1
echo "👍🏻 Correctly calculated Getter & Setter complexity"
