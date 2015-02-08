

vector(vector a, vector b) crossproduct =
{
	local vector result;
	result_x = (a_y * b_z) - (a_z * b_y);
	result_y = (a_z * b_x) - (a_x * b_z);
	result_z = (a_x * b_y) - (a_y * b_x);
	return result;
}