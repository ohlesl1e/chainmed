#!/usr/bin/env python3
import pandas

if __name__ == "__main__":
    df = pandas.read_csv('../product.csv', header=0)
    df.sort_values('STARTMARKETINGDATE', inplace=True,)
    df.drop_duplicates(['PROPRIETARYNAME', 'NONPROPRIETARYNAME', 'DOSAGEFORMNAME',
                       'ACTIVE_NUMERATOR_STRENGTH'], keep='last', inplace=True)
    df.sort_values('PROPRIETARYNAME', inplace=True,)
    df.to_csv('../product_processed.csv', index=False)
