const std = @import("std");
const Graphics = @import("./graphics.zig");
const Vec3 = Graphics.Vector3;
const Ray = Graphics.Ray;
const Color = Vec3;
const print = std.debug.print;

const aspect_ratio: f64 = 16.0 / 9.0;
const image_width = 400;
const image_height: u32 = if (@as(u32, @intFromFloat(image_width / aspect_ratio)) < 1) 1 else @as(u32, @intFromFloat(image_width / aspect_ratio));

// Camera
const viewport_height = 2.0;
const viewport_width = viewport_height * (@as(f64, @floatFromInt(image_width)) / image_height);
const camera_center = Vec3.zero();
const focal_length = 1.0;

// Calculate the vectors across the horizontal and down the vertical viewport edges.
const viewport_u = Vec3.init(viewport_width, 0, 0);
const viewport_v = Vec3.init(0, -viewport_height, 0);

// Calculate the horizontal and vertical delta vectors from pixel to pixel.
const pixel_delta_u = viewport_u.divide_by(image_width);
const pixel_delta_v = viewport_v.divide_by(image_height);

// Calculate the location of the upper left pixel.
// auto viewport_upper_left = camera_center - vec3(0, 0, focal_length) - viewport_u/2 - viewport_v/2;
// auto pixel00_loc = viewport_upper_left + 0.5 * (pixel_delta_u + pixel_delta_v);

const viewport_upper_left = camera_center.minus(Vec3.init(0, 0, focal_length)).minus(viewport_u.divide_by(2)).minus(viewport_v.divide_by(2));
const pixel100_loc = viewport_upper_left.plus(pixel_delta_u.plus(pixel_delta_v).times(0.5));

fn test_prints() void {
    print(" ==== Basic Settings ==== \n", .{});
    print("Aspect Ratio: {d:.2} \nImage Width: {} \nImage Height: {} \nViewport Height: {d:.2} \nViewport Width: {d:.2} \n\n", .{ aspect_ratio, image_width, image_height, viewport_height, viewport_width });

    const vec1 = Vec3.one().times(3);
    const vec2 = Vec3.one().times(5);
    var ray = Ray.init(vec1, vec2);

    print(" ==== Calculated Values ==== ", .{});
    print_nl(1);
    print("{}", .{viewport_upper_left});
    print_nl(1);
    print("{}", .{pixel100_loc});
    print_nl(2);

    print(" ====  RAYS  ==== ", .{});
    print_nl(1);
    print("Origin: {}", .{ray.origin});
    print("Direction: {}", .{ray.direction});
    print("Ray.at: {}", .{ray.at(1)});
}

pub fn writeColor(writer: anytype, pixel_color: Color) !void {
    const r = pixel_color.x;
    const g = pixel_color.y;
    const b = pixel_color.z;

    const rbyte = @as(u8, @intFromFloat(255.999 * r));
    const gbyte = @as(u8, @intFromFloat(255.999 * g));
    const bbyte = @as(u8, @intFromFloat(255.999 * b));

    try writer.print("{} {} {}\n", .{ rbyte, gbyte, bbyte });
}

fn rayColor(r: Ray) Color {
    // blendedValue=(1−𝑎)⋅startValue+𝑎⋅endValue,

    // vec3 unit_direction = unit_vector(r.direction());
    // auto a = 0.5*(unit_direction.y() + 1.0);
    // return (1.0-a)*color(1.0, 1.0, 1.0) + a*color(0.5, 0.7, 1.0);
    // return color(1.0, 1.0, 1.0) * (1.0-a) + color(0.5, 0.7, 1.0) * a;

    // print("UNIT VECTOR: {}", .{r.direction.unitize()});

    // if (hit_sphere(point3(0,0,-1), 0.5, r))
    // return color(1, 0, 0);
    const sphere_origin = Vec3.init(0, 0, -1);
    const t = hitSphere(sphere_origin, 0.5, r);
    if (t > 0) {
        const n = r.at(t).minus(Vec3.init(0, 0, -1)).unitize();
        return Color.init(n.x + 1, n.y + 1, n.z + 1).times(0.5);
    }

    const unit_direction = r.direction.unitize();
    const a = 0.5 * (unit_direction.y + 1.0);

    return Color.one().times(1.0 - a).plus((Color.init(0.5, 0.7, 1.0).times(a)));
}

fn hitSphere(center: Vec3, radius: f64, ray: Ray) f64 {
    //   bool hit_sphere(const point3& center, double radius, const ray& r) {
    //     vec3 oc = center - r.origin();
    //     auto a = dot(r.direction(), r.direction());
    //     auto b = -2.0 * dot(r.direction(), oc);
    //     auto c = dot(oc, oc) - radius*radius;
    //     auto discriminant = b*b - 4*a*c;
    //      if (discriminant < 0) {
    //        return -1.0;
    //       } else {
    //        return (-b - std::sqrt(discriminant) ) / (2.0*a);
    //       }
    //   }
    const oc = center.minus(ray.origin);
    const a = Vec3.dot(ray.direction, ray.direction);
    const b = -2.0 * Vec3.dot(ray.direction, oc);
    const c = Vec3.dot(oc, oc) - radius * radius;
    const discriminant = b * b - 4 * a * c;

    return if (discriminant < 0) -1.0 else -b - @sqrt(discriminant) / (2.0 * a);
}

pub fn main() !void {
    test_prints();

    const img_file = try std.fs.cwd().createFile("output.ppm", .{ .read = true });
    const writer = img_file.writer();
    defer img_file.close();

    try writer.print("P3\n{} {}\n255\n", .{ image_width, image_height });
    // std::cout << "P3\n" << image_width << ' ' << image_height << "\n255\n";

    for (0..image_height) |j| {
        print("\r Scanlines Remaining: {}  ", .{image_height - j});
        for (0..image_width) |i| {
            const pixel_center = pixel100_loc.plus(pixel_delta_u.times(@as(f64, @floatFromInt(i))).plus(pixel_delta_v.times(@as(f64, @floatFromInt(j)))));
            const ray_direction = pixel_center.minus(camera_center);
            const ray = Ray.init(camera_center, ray_direction);

            const pixel_color = rayColor(ray);
            try writeColor(writer, pixel_color);
        }
    }
}

fn print_nl(comptime n: u8) void {
    inline for (0..n) |_| {
        print("\n", .{});
    }
}
