#!/usr/bin/env bash
# SPDX-FileCopyrightText: Copyright (c) 2021-2025 Yegor Bugayenko
# SPDX-License-Identifier: MIT
set -e
set -o pipefail

temp=$1
stdout=$2

{
    java="${temp}/Foo(xls;)';a привет '\".java"
    cat > "${java}" <<EOT
    class Foo extends Boo implements Bar {
        // This is static
        private static int X = 1;
        private String z;

        Foo(String zz) {
            this.z = zz;
        }
        private final boolean boom() { return true; }
    }
EOT
    msg=$("${LOCAL}/steps/measure-file.sh" "${java}" "${temp}/m1")
    echo "${msg}"
    set -x
    test "$(echo "${msg}" | grep -c "sum=0")" = 0
    all=$(find "${temp}" -name 'm1.*' -type f -exec basename {} \; | sort)
    echo "${all}" | sort | while IFS= read -r m; do
        metric=${m//m\./}
        echo "${metric}: $(cat "${temp}/${m}")"
    done
    test "$(cat "${temp}/m1.LoC")" = "8.000"
    test "$(cat "${temp}/m1.NoCL")" = "1.000"
    test "$(cat "${temp}/m1.CC")" = "1.000"
    test "$(cat "${temp}/m1.NCSS")" = "7.000"
    test "$(cat "${temp}/m1.NoCM")" = "0.000"
    test "$(cat "${temp}/m1.NoOM")" = "1.000"
    test "$(cat "${temp}/m1.NoCC")" = "1.000"
    test "$(cat "${temp}/m1.NAPC")" = "1.000"
    test "$(cat "${temp}/m1.NoII")" = "1.000"
    test "$(cat "${temp}/m1.NoTP")" = "0.000"
    test "$(cat "${temp}/m1.Final")" = "0.000"
    test "$(cat "${temp}/m1.NoBL")" = "1.000"
    test "$(cat "${temp}/m1.HSD")" = "6.187"
    test "$(cat "${temp}/m1.HSV")" = "122.623"
    test "$(cat "${temp}/m1.HSE")" = "758.735"
    test "$(cat "${temp}/m1.CoCo")" = "0.000"
    test "$(cat "${temp}/m1.FOut")" = "0.000"
    test "$(cat "${temp}/m1.LCOM5")" = "0.000"
    test "$(cat "${temp}/m1.RAF")" = "0.000"
    test "$(cat "${temp}/m1.NULLs")" = "0.000"
    set +x
} > "${stdout}" 2>&1
echo "👍🏻 Single file measured correctly"

{
    java=${temp}/bad.java
    echo "this is not Java, but a broken syntax" > "${java}"
    msg=$("${LOCAL}/steps/measure-file.sh" "${java}" "${temp}/m2")
    echo "${msg}"
    echo "${msg}" | grep "Failed to collect ast.py"
    echo "${msg}" | grep "Failed to collect cyclomatic_complexity.py"
    test -e "${temp}/m2.CoCo"
    test -e "${temp}/m2.LoC"
    test ! -e "${temp}/m2.CC"
} > "${stdout}" 2>&1
echo "👍🏻 Broken syntax measured and error log created"

{
    java="${temp}/Foo.java"
    cat > "${java}" <<EOT
    class Foo extends Boo implements Bar {
        // This is static
        private static int X = 1;
        private String z;

        Foo(String zz) {
            this.z = zz;
        }
        private final boolean boom() { return true; }
    }
EOT
    msg=$("${LOCAL}/steps/measure-file.sh" "${java}" "${temp}/m3")
    all=$(find "${temp}" -name 'm3.*' -type f -exec basename {} \; | sort)
    actual_number_of_metrics_simple=$(echo "${all}" | wc -l | xargs)


    java=${temp}/Complex.java
    cat > "${java}" <<EOT
    import java.util.Objects;

    public class Complex {
        private final double re;   // the real part
        private final double im;   // the imaginary part

        // create a new object with the given real and imaginary parts
        public Complex(double real, double imag) {
            re = real;
            im = imag;
        }

        // return a string representation of the invoking Complex object
        public String toString() {
            if (im == 0) return re + "";
            if (re == 0) return im + "i";
            if (im <  0) return re + " - " + (-im) + "i";
            return re + " + " + im + "i";
        }

        // return abs/modulus/magnitude
        public double abs() {
            return Math.hypot(re, im);
        }

        // return angle/phase/argument, normalized to be between -pi and pi
        public double phase() {
            return Math.atan2(im, re);
        }

        // return a new Complex object whose value is (this + b)
        public Complex plus(Complex b) {
            Complex a = this;             // invoking object
            double real = a.re + b.re;
            double imag = a.im + b.im;
            return new Complex(real, imag);
        }

        // return a new Complex object whose value is (this - b)
        public Complex minus(Complex b) {
            Complex a = this;
            double real = a.re - b.re;
            double imag = a.im - b.im;
            return new Complex(real, imag);
        }

        // return a new Complex object whose value is (this * b)
        public Complex times(Complex b) {
            Complex a = this;
            double real = a.re * b.re - a.im * b.im;
            double imag = a.re * b.im + a.im * b.re;
            return new Complex(real, imag);
        }

        // return a new object whose value is (this * alpha)
        public Complex scale(double alpha) {
            return new Complex(alpha * re, alpha * im);
        }

        // return a new Complex object whose value is the conjugate of this
        public Complex conjugate() {
            return new Complex(re, -im);
        }

        // return a new Complex object whose value is the reciprocal of this
        public Complex reciprocal() {
            double scale = re*re + im*im;
            return new Complex(re / scale, -im / scale);
        }

        // return the real or imaginary part
        public double re() { return re; }
        public double im() { return im; }

        // return a / b
        public Complex divides(Complex b) {
            Complex a = this;
            return a.times(b.reciprocal());
        }

        // return a new Complex object whose value is the complex exponential of this
        public Complex exp() {
            return new Complex(Math.exp(re) * Math.cos(im), Math.exp(re) * Math.sin(im));
        }

        // return a new Complex object whose value is the complex sine of this
        public Complex sin() {
            return new Complex(Math.sin(re) * Math.cosh(im), Math.cos(re) * Math.sinh(im));
        }

        // return a new Complex object whose value is the complex cosine of this
        public Complex cos() {
            return new Complex(Math.cos(re) * Math.cosh(im), -Math.sin(re) * Math.sinh(im));
        }

        // return a new Complex object whose value is the complex tangent of this
        public Complex tan() {
            return sin().divides(cos());
        }



        // a static version of plus
        public static Complex plus(Complex a, Complex b) {
            double real = a.re + b.re;
            double imag = a.im + b.im;
            Complex sum = new Complex(real, imag);
            return sum;
        }

        // See Section 3.3.
        public boolean equals(Object x) {
            if (x == null) return false;
            if (this.getClass() != x.getClass()) return false;
            Complex that = (Complex) x;
            return (this.re == that.re) && (this.im == that.im);
        }

        // See Section 3.3.
        public int hashCode() {
            return Objects.hash(re, im);
        }

        // sample client for testing
        public static void main(String[] args) {
            Complex a = new Complex(5.0, 6.0);
            Complex b = new Complex(-3.0, 4.0);

            StdOut.println("a            = " + a);
            StdOut.println("b            = " + b);
            StdOut.println("Re(a)        = " + a.re());
            StdOut.println("Im(a)        = " + a.im());
            StdOut.println("b + a        = " + b.plus(a));
            StdOut.println("a - b        = " + a.minus(b));
            StdOut.println("a * b        = " + a.times(b));
            StdOut.println("b * a        = " + b.times(a));
            StdOut.println("a / b        = " + a.divides(b));
            StdOut.println("(a / b) * b  = " + a.divides(b).times(b));
            StdOut.println("conj(a)      = " + a.conjugate());
            StdOut.println("|a|          = " + a.abs());
            StdOut.println("tan(a)       = " + a.tan());
        }
    }
EOT
    msg=$("${LOCAL}/steps/measure-file.sh" "${java}" "${temp}/m4")
    all=$(find "${temp}" -name 'm4.*' -type f -exec basename {} \; | sort)
    actual_number_of_metrics_complex=$(echo "${all}" | wc -l | xargs)

    if [ "${actual_number_of_metrics_simple}" != "${actual_number_of_metrics_complex}" ]; then
        echo "🚨 Number of metrics does not match for simple and complicated Java files. For simple: ${actual_number_of_metrics_simple}, for complex: ${actual_number_of_metrics_complex}"
        exit 1
    fi
} > "${stdout}" 2>&1
echo "👍🏻 Number of metrics matches for simple and complex Java files: ${actual_number_of_metrics_simple} metrics"
