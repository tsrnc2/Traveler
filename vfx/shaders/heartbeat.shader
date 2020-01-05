shader_type canvas_item;



void vertex() {
// Output:0

}

void fragment() {
// Input:2
	float n_out2p0;
	n_out2p0 = TIME;

// ScalarFunc:3
	float n_out3p0;
	n_out3p0 = sin(n_out2p0);

// Output:0
	COLOR.a = n_out3p0;

}

void light() {
// Output:0

}
