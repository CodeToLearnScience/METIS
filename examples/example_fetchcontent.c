#include <metis.h>
#include <stdio.h>

int main() {
    // Simple example showing METIS can be used
    idx_t nvtxs = 6;
    idx_t ncon = 1;
    idx_t xadj[] = {0, 2, 5, 8, 11, 13, 15};
    idx_t adjncy[] = {1, 3, 0, 2, 4, 1, 3, 5, 0, 2, 4, 1, 5, 2, 4};
    idx_t nparts = 2;
    idx_t objval;
    idx_t part[6];
    
    int ret = METIS_PartGraphKway(&nvtxs, &ncon, xadj, adjncy, NULL, NULL, 
                                   NULL, &nparts, NULL, NULL, NULL, 
                                   &objval, part);
    
    if (ret == METIS_OK) {
        printf("METIS partitioning successful!\n");
        printf("Edge-cut: %d\n", (int)objval);
        printf("Partition assignment: ");
        for (int i = 0; i < nvtxs; i++) {
            printf("%d ", (int)part[i]);
        }
        printf("\n");
        return 0;
    } else {
        printf("METIS partitioning failed!\n");
        return 1;
    }
}
