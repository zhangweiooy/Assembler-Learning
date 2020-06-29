#include <stdio.h>

int main()
{
	int count = 0;
	int i, j, k, l;
	for (i = 0; i < 10; i++)
		for (j = 0; j < 10; j++)
			for (k = 0; k < 10; k++)
				for (l = 0; l < 10; l++)
				{
					count++;
				}
	printf("%d\n", count);
	return 0;
}
