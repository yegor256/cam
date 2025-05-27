/*
 * SPDX-FileCopyrightText: Copyright (c) 2021-2025 Yegor Bugayenko
 * SPDX-License-Identifier: MIT
 */
/*
 [The "BSD license"]
 Copyright (c) 2011-2025 Joel Li (李家智)
 All rights reserved.

 Redistribution and use in source and binary forms, with or without
 modification, are permitted provided that the following conditions
 are met:
 1. Redistributions of source code must retain the above copyright
     notice, this list of conditions and the following disclaimer.
 2. Redistributions in binary form must reproduce the above copyright
     notice, this list of conditions and the following disclaimer in the
     documentation and/or other materials provided with the distribution.
 3. The name of the author may not be used to endorse or promote products
     derived from this software without specific prior written permission.

 THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
 IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
 OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
 IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
 INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
 NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
 DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
 THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
 (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
 THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */
package org.beetl.ext.fn;

import java.util.regex.Matcher;
import java.util.regex.Pattern;

import org.beetl.core.Context;
import org.beetl.core.Function;

/**
 *
 * @author 张健川 dlut.zjc@gmail.com ,xiandafu
 */
public class ParseDouble implements Function
{

    @Override
    public Object call(Object[] paras, Context ctx)
    {
        Object o = paras[0];
        if (o == null)
            throw new NullPointerException("Error:parseDouble(null)");
        String str = "";
        double result;
        if (o instanceof Number)
        {
            Double n = ((Number) o).doubleValue();
            return n;
        }
        else
        {
            str = o.toString();
        }
        try
        {
            result = Double.parseDouble(str);
        }
        catch (NumberFormatException e)
        {
            throw new RuntimeException("不能转化"+str,e);
        }

        return result;
    }

        public static void main(String[] args)
        {
            Double d = 1232323232323.89;
            System.out.println(d);
            String str = d.toString();
            double c = Double.parseDouble(str);
            System.out.println(c);
            ParseDouble pDouble = new ParseDouble();
            Context ctx = new Context();
            System.out.println(pDouble.call(new Object[]
            { -01.}, ctx));
            System.out.println(pDouble.call(new Object[]
            { 2332.23213 }, ctx));
            System.out.println(pDouble.call(new Object[]
            { "-1.023" }, ctx));
            System.out.println(pDouble.call(new Object[]
            { "abcd" }, ctx));
        }
}
