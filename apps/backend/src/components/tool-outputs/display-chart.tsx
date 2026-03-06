import type { displayChart } from '@lysmart/shared/tools';

import { Block } from '../../lib/markdown';

export function DisplayChartOutput({ output }: { output: displayChart.Output }) {
	if (output.error) {
		return <Block>Could not display the chart: {output.error}</Block>;
	}
	return <Block>Chart displayed successfully.</Block>;
}
