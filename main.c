#include <stdio.h>

extern double matrixsum_cc(int sz, double* ptr, int mattype);
extern double matrixsum2_cc(int sz, double* ptr, int mattype);

int main() {
    double matrix[9] = {1,2,3,4,5,6,7,8,9};  // 3x3 matrix
    double result = matrixsum_cc(3, matrix, 1);
    double result2 = matrixsum_cc(3, matrix, 1);
    printf("Sum : %f\n", result);
    printf("Sum2: %f\n", result2);

    double matrix_diag[3] = {1,2,3};  // 3x3 diagonal matrix
    result = matrixsum_cc(3, matrix_diag, 2);
    result2 = matrixsum_cc(3, matrix_diag, 2);
    printf("Sum : %f\n", result);
    printf("Sum2: %f\n", result2);
    return 0;
}
