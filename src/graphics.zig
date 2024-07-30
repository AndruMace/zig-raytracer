const std = @import("std");

pub const Ray = struct {
    origin: Vector3,
    direction: Vector3,

    pub fn zero() Ray {
        return Ray{ .origin = Vector3.zero(), .direction = Vector3.zero() };
    }

    pub fn init(origin: Vector3, direction: Vector3) Ray {
        return Ray{ .origin = origin, .direction = direction };
    }

    pub fn at(self: Ray, t: f64) Vector3 {
        const pos_at = self.origin.plus(self.direction.times(t));
        return pos_at;
    }
};

pub const Vector3 = struct {
    x: f64,
    y: f64,
    z: f64,

    pub fn zero() Vector3 {
        return Vector3{ .x = 0, .y = 0, .z = 0 };
    }

    pub fn one() Vector3 {
        return Vector3{ .x = 1, .y = 1, .z = 1 };
    }

    pub fn init(x: f64, y: f64, z: f64) Vector3 {
        return Vector3{ .x = x, .y = y, .z = z };
    }

    pub fn negate(self: Vector3) Vector3 {
        return Vector3.init(-self.x, -self.y, -self.z);
    }

    pub fn plus(self: Vector3, v: Vector3) Vector3 {
        return Vector3.init(self.x + v.x, self.y + v.y, self.z + v.z);
    }

    pub fn minus(self: Vector3, v: Vector3) Vector3 {
        return Vector3.init(self.x - v.x, self.y - v.y, self.z - v.z);
    }

    pub fn times(self: Vector3, multiplier: f64) Vector3 {
        return Vector3.init(self.x * multiplier, self.y * multiplier, self.z * multiplier);
    }

    pub fn divide_by(self: Vector3, divisor: f64) Vector3 {
        const frac = 1 / divisor;
        return Vector3.init(self.x * frac, self.y * frac, self.z * frac);
    }

    pub fn magnitude(self: Vector3) f64 {
        return @sqrt(sq(self.x) + sq(self.y) + sq(self.z));
    }

    pub fn unitize(self: Vector3) Vector3 {
        return self.divide_by(self.magnitude());
    }

    pub fn dot(u: Vector3, v: Vector3) f64 {
        return (u.x * v.x) + (u.y * v.y) + (u.z * v.z);
    }

    pub fn format(self: Vector3, comptime fmt: []const u8, options: std.fmt.FormatOptions, writer: anytype) !void {
        _ = fmt;
        _ = options;

        try writer.print("Vector3{{{d:.2}, ", .{self.x});
        try writer.print("{d:.2}, ", .{self.y});
        try writer.print("{d:.2}", .{self.z});
        try writer.writeAll("} ");
    }

    // Math utilities
    fn sq(n: f64) f64 {
        return n * n;
    }
};
