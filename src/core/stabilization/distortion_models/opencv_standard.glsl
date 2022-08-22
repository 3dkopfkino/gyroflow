// SPDX-License-Identifier: GPL-3.0-or-later
// Copyright © 2022 Adrian <adrian.eddy at gmail>

vec2 undistort_point(vec2 pos, vec4 k1, vec4 k2, vec4 k3, float amount) {
    vec2 start_pos = pos;

    // compensate distortion iteratively
    for (int i = 0; i < 20; ++i) {
        float r2 = pos.x * pos.x + pos.y * pos.y;
        float icdist = (1.0 + ((k2.w * r2 + k2.z) * r2 + k2.y) * r2)/(1.0 + ((k2.x * r2 + k1.y) * r2 + k1.x) * r2);
        if (icdist < 0.0) {
            return vec2(0.0, 0.0);
        }
        float delta_x = 2.0 * k1.z * pos.x * pos.y + k1.w * (r2 + 2.0 * pos.x * pos.x)+ k3.x * r2 + k3.y * r2 * r2;
        float delta_y = k1.z * (r2 + 2.0 * pos.y * pos.y) + 2.0 * k1.w * pos.x * pos.y+ k3.z * r2 + k3.w * r2 * r2;
        pos = vec2(
            (start_pos.x - delta_x) * icdist,
            (start_pos.y - delta_y) * icdist
        );
    }

    return vec2(
        pos.x * (amount - 1.0) + start_pos.x * amount,
        pos.y * (amount - 1.0) + start_pos.y * amount
    );
}

vec2 distort_point(vec2 pos, vec4 k1, vec4 k2, vec4 k3) {
    float r2 = pos.x * pos.x + pos.y * pos.y;
    float r4 = r2 * r2;
    float r6 = r4 * r2;
    float a1 = 2.0 * pos.x * pos.y;
    float a2 = r2 + 2.0 * pos.x * pos.x;
    float a3 = r2 + 2.0 * pos.y * pos.y;
    float cdist = 1.0 + k1.x * r2 + k1.y * r4 + k2.x * r6;
    float icdist2 = 1.0 / (1.0 + k2.y * r2 + k2.z * r4 + k2.w * r6);

    return vec2(
        pos.x * cdist * icdist2 + k1.z * a1 + k1.w * a2 + k3.x  * r2 + k3.y  * r4,
        pos.y * cdist * icdist2 + k1.z * a3 + k1.w * a1 + k3.z * r2 + k3.w * r4
    );
}
