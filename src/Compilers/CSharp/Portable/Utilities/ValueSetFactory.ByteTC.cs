﻿// Licensed to the .NET Foundation under one or more agreements.
// The .NET Foundation licenses this file to you under the MIT license.
// See the LICENSE file in the project root for more information.

using System;
using System.Diagnostics;

#nullable enable

namespace Microsoft.CodeAnalysis.CSharp
{
    using static BinaryOperatorKind;

    internal static partial class ValueSetFactory
    {
        private struct ByteTC : INumericTC<byte>
        {
            byte INumericTC<byte>.MinValue => byte.MinValue;

            byte INumericTC<byte>.MaxValue => byte.MaxValue;

            (byte leftMax, byte rightMin) INumericTC<byte>.Partition(byte min, byte max)
            {
                Debug.Assert(min < max);
                int half = (max - min) / 2;
                byte leftMax = (byte)(min + half);
                byte rightMin = (byte)(leftMax + 1);
                return (leftMax, rightMin);
            }

            bool INumericTC<byte>.Related(BinaryOperatorKind relation, byte left, byte right)
            {
                switch (relation)
                {
                    case Equal:
                        return left == right;
                    case GreaterThanOrEqual:
                        return left >= right;
                    case GreaterThan:
                        return left > right;
                    case LessThanOrEqual:
                        return left <= right;
                    case LessThan:
                        return left < right;
                    default:
                        throw new ArgumentException("relation");
                }
            }

            byte INumericTC<byte>.Next(byte value)
            {
                Debug.Assert(value != byte.MaxValue);
                return (byte)(value + 1);
            }

            byte INumericTC<byte>.FromConstantValue(ConstantValue constantValue) => constantValue.ByteValue;

            string INumericTC<byte>.ToString(byte value) => value.ToString();
        }
    }
}