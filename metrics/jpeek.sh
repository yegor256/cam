#!/bin/bash
# The MIT License (MIT)
#
# Copyright (c) 2021-2022 Yegor Bugayenko
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

set -e
set -o pipefail

java=$1
output=$2

sample="MMAC NaN Method-Method through Attributes Cohesion. The MMAC is the average cohesion of all pairs of methods. In simple words this metric shows how many methods have the same parameters or return types. When class has some number of methods and most of them operate the same parameters it assumes better. It looks like class contains overloaded methods. Preferably when class has only one method with parameters and/or return type and it assumes that class do only one thing. Value of MMAC metric is better for these one classes. Metric value is in interval [0, 1]. Value closer to 1 is better.
CAMC NaN The Cohesion Among Methods in Class (CAMC) measures the extent of intersections of individual method parameter type lists with the parameter type list of all methods in the class.
NHD NaN The NHD (Normalized Hamming Distance) class cohesion metric is based on the \"Hamming distance\" from information theory. Here, we measure the similarity in all methods of a class in terms of the types of their arguments. A class in which all methods accept the same set of types of parameters is said to be in \"perfect parameter agreement\" (NHD score \"1\"), whereas a class in which all methods accept unique parameter types not shared by others has no parameter agreement (NHD score \"0\").
LCOM5 NaN 'LCOM5' is a 1996 revision by B. Henderson-Sellers, L. L. Constantine, and I. M. Graham, of the initial LCOM metric proposed by MIT researchers. The values for LCOM5 are defined in the real interval [0, 1] where '0' describes \"perfect cohesion\" and '1' describes \"no cohesion\". Two problems with the original definition are addressed: a) LCOM5 has the ability to give values across the full range and no specific value has a higher probability of attainment than any other (the original LCOM has a preference towards the value \"0\") b) Following on from the previous point, the values can be uniquely interpreted in terms of cohesion, suggesting that they be treated as percentages of the \"no cohesion\" score '1'
SCOM NaN \"Sensitive Class Cohesion Metric\" (SCOM) notes some deficits in the LCOM5 metric, particularly how it fails in some cases to discriminate (ie. it assigns the same score) between classes where one is clearly more cohesive than the other. In these cases, SCOM is more \"sensitive\" than LCOM5 because it evaluates to different values. Like LCOM5, SCOM values lie in the range [0..1], but their meanings are inverted: \"0\" indicates no cohesion at all (i.e. every method deals with an independent set of attributes), whereas \"1\" indicates full cohesion (ie. every method uses all the attributes of the class). This inversion stems from SCOM measuring how much \"agreement\" there is among the methods, unlike LCOM which measures how much \"disagreement\" there is. Another important distinction is that SCOM assigns \"weights\" to each pair of methods computed equal to the proportion of total attributes being used between the two. This contributes to the metric's \"sensitivity\". Finally, the authors provide a formula for the minimum value beyond which \"we can claim that [the class] has at least two clusters and it must be subdivided into smaller, more cohesive classes\".
MMAC(cvc) NaN Same as MMAC, but in this case, the constructors are excluded from the metric formulas.
CAMC(cvc) NaN Same as CAMC, but in this case, the constructors are excluded from the metric formulas.
NHD(cvc) NaN Same as NHD, but in this case, the constructors are excluded from the metric formulas.
LCOM5(cvc) NaN Same as LCOM5, but in this case, the constructors are excluded from the metric formulas.
SCOM(cvc) NaN Same as SCOM, but in this case, the constructors are excluded from the metric formulas."

file="${java//github/jpeek}"
out=""
if [ -e "${file}" ] && [ "${file}" != "${java}" ]; then
	out="$(cat "${file}")"
else
	out="${sample}"
fi

cat <<EOT> "${output}"
${out}
EOT
