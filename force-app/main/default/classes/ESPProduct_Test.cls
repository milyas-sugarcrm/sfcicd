@isTest
public class ESPProduct_Test {
  public static testMethod void testParse() {
    String json =
      '{' +
      '    \"Id\": 4954262,' +
      '    \"Name\": \"Brand Gear™ Stainless Steel Travel Mug™\",' +
      '    \"Description\": \"Nothing says \\\"I appreciate you\\\" like the 12 oz. Brand Gear™ Stainless Steel Travel Mug! Measuring 6\\\" x 3 1/2\\\" the stainless steel mug includes an ergonomic handle, BPA-free liner, stainless steel casing and no-spill lid with sliding cap. Double insulation keeps your beverages hot or cold and the product features VibraColor® domes on both the front and handle. Please be advised the mug is not intended for either the microwave or dishwasher.\",' +
      '    \"ShortDescription\": \"Stainless steel 6\\\" (tall) x 3 1/2\\\"  diameter, 12 oz travel mug with ergonomic handle.\",' +
      '    \"Number\": \"AiO-STMUG\",' +
      '    \"Numbers\": [' +
      '        \"AiO-STMUG\"' +
      '    ],' +
      '    \"ImageUrl\": \"media/22654946\",' +
      '    \"VirtualSampleImages\": [' +
      '        {' +
      '            \"Id\": 22654946,' +
      '            \"Description\": \"pg0118-AiO-STMUG.jpg\",' +
      '            \"ImageUrl\": \"virtualsample/22654946\",' +
      '            \"IsPrimary\": true,' +
      '            \"IsVirtualSample\": true' +
      '        }' +
      '    ],' +
      '    \"Supplier\": {' +
      '        \"Id\": 276,' +
      '        \"Name\": \"ALL-IN-ONE\",' +
      '        \"AsiNumber\": \"34256\",' +
      '        \"Phone\": {' +
      '            \"Work\": \"(858) 695-0427\",' +
      '            \"TollFree\": \"(800) THE-PENS\",' +
      '            \"Primary\": \"(858) 695-0427\",' +
      '            \"$index\": 1' +
      '        },' +
      '        \"Fax\": {' +
      '            \"TollFree\": \"(800) 533-7367\",' +
      '            \"Primary\": \"(800) 533-7367\",' +
      '            \"$index\": 1' +
      '        },' +
      '        \"Email\": \"orders@allinoneline.com\",' +
      '        \"Websites\": [' +
      '            \"http://www.allinoneline.com\"' +
      '        ],' +
      '        \"MarketingPolicy\": \"Supplier indicates they sell advertising specialties exclusively through distributors and/or incentive resellers\",' +
      '        \"IsMinorityOwned\": false' +
      '    },' +
      '    \"LineNames\": [' +
      '        \"ALL-IN-ONE®\"' +
      '    ],' +
      '    \"Catalog\": {' +
      '        \"Id\": 205471,' +
      '        \"Name\": \"All-In-One-2016-Catalog\",' +
      '        \"Year\": \"2016\",' +
      '        \"Asset\": \"ASI/34256-205471 2016 All-In-One Catalog\",' +
      '        \"MaskedAsset\": \"ASI/34256-205471 2016 All-In-One Catalog-M\",' +
      '        \"CompanyId\": 0,' +
      '        \"ProductCount\": 0,' +
      '        \"EndUserSafe\": false' +
      '    },' +
      '    \"Catalogs\": [' +
      '        {' +
      '            \"Id\": 205471,' +
      '            \"Name\": \"All-In-One-2016-Catalog\",' +
      '            \"Year\": \"2016\",' +
      '            \"Asset\": \"ASI/34256-205471 2016 All-In-One Catalog\",' +
      '            \"MaskedAsset\": \"ASI/34256-205471 2016 All-In-One Catalog-M\",' +
      '            \"CompanyId\": 0,' +
      '            \"ProductCount\": 0,' +
      '            \"EndUserSafe\": false' +
      '        }' +
      '    ],' +
      '    \"Categories\": [' +
      '        {' +
      '            \"Id\": \"M09315103\",' +
      '            \"Name\": \"Insulated\",' +
      '            \"Parent\": {' +
      '                \"Id\": \"M09310003\",' +
      '                \"Name\": \"Mugs & Steins\"' +
      '            }' +
      '        },' +
      '        {' +
      '            \"Id\": \"T07560003\",' +
      '            \"Name\": \"Travel Mugs/cups\"' +
      '        }' +
      '    ],' +
      '    \"Themes\": [' +
      '        \"Eco Friendly\"' +
      '    ],' +
      '    \"TradeNames\": [' +
      '        \"Brand Gear™\",' +
      '        \"Stainless Steel Travel Mug™\"' +
      '    ],' +
      '    \"ProductionTime\": [' +
      '        {' +
      '            \"Name\": \"10 business days\",' +
      '            \"Description\": \"10 working days \",' +
      '            \"Days\": 10' +
      '        }' +
      '    ],' +
      '    \"Attributes\": {' +
      '        \"Colors\": {' +
      '            \"Values\": [' +
      '                {' +
      '                    \"Code\": \"BLCK\",' +
      '                    \"Name\": \"Stainless Steel-Black\",' +
      '                    \"$index\": 3' +
      '                }' +
      '            ]' +
      '        },' +
      '        \"Sizes\": {' +
      '            \"Values\": [' +
      '                {' +
      '                    \"Code\": \"GTWE\",' +
      '                    \"Name\": \"12 oz\",' +
      '                    \"Description\": \"none\",' +
      '                    \"$index\": 3' +
      '                }' +
      '            ]' +
      '        },' +
      '        \"Materials\": {' +
      '            \"Values\": [' +
      '                {' +
      '                    \"Code\": \"$02X\",' +
      '                    \"Name\": \"Stainless Steel\",' +
      '                    \"$index\": 3' +
      '                }' +
      '            ]' +
      '        }' +
      '    },' +
      '    \"Imprinting\": {' +
      '        \"Methods\": {' +
      '            \"Values\": [' +
      '                {' +
      '                    \"Code\": \"$0TQ\",' +
      '                    \"Name\": \"VibraColor(R)\",' +
      '                    \"Charges\": [' +
      '                        {' +
      '                            \"TypeCode\": \"STCH\",' +
      '                            \"Type\": \"Set-up Charge\",' +
      '                            \"Description\": \"VibraColor Set Up\",' +
      '                            \"Prices\": [' +
      '                                {' +
      '                                    \"Quantity\": {' +
      '                                        \"From\": 1,' +
      '                                        \"To\": 2147483647,' +
      '                                        \"$index\": 1' +
      '                                    },' +
      '                                    \"Price\": 55,' +
      '                                    \"Cost\": 44,' +
      '                                    \"DiscountCode\": \"V\",' +
      '                                    \"CurrencyCode\": \"USD\",' +
      '                                    \"IsQUR\": false' +
      '                                }' +
      '                            ],' +
      '                            \"UsageLevelCode\": \"PORD\",' +
      '                            \"UsageLevel\": \"Per Order\",' +
      '                            \"IsRequired\": true' +
      '                        }' +
      '                    ],' +
      '                    \"$index\": 3' +
      '                }' +
      '            ]' +
      '        },' +
      '        \"Services\": {' +
      '            \"Values\": [' +
      '                {' +
      '                    \"Code\": \"$2HH\",' +
      '                    \"Name\": \"Pre-production Proof\",' +
      '                    \"Description\": \"Upon written approval. \",' +
      '                    \"Charges\": [' +
      '                        {' +
      '                            \"TypeCode\": \"PROF\",' +
      '                            \"Type\": \"Proof Charge\",' +
      '                            \"Description\": \"Pre-production Proof\",' +
      '                            \"Prices\": [' +
      '                                {' +
      '                                    \"Quantity\": {' +
      '                                        \"From\": 1,' +
      '                                        \"To\": 2147483647,' +
      '                                        \"$index\": 1' +
      '                                    },' +
      '                                    \"Price\": 35,' +
      '                                    \"Cost\": 28,' +
      '                                    \"DiscountCode\": \"V\",' +
      '                                    \"CurrencyCode\": \"USD\",' +
      '                                    \"IsQUR\": false' +
      '                                }' +
      '                            ],' +
      '                            \"PriceIncludes\": \"per imprint color/location, or no charge on orders of 10,000 units or more.\",' +
      '                            \"UsageLevelCode\": \"PORD\",' +
      '                            \"UsageLevel\": \"Per Order\",' +
      '                            \"IsRequired\": true' +
      '                        }' +
      '                    ],' +
      '                    \"$index\": 3' +
      '                },' +
      '                {' +
      '                    \"Code\": \"$2HH\",' +
      '                    \"Name\": \"Virtual Proof\",' +
      '                    \"Description\": \"Upon written approval. \",' +
      '                    \"Charges\": [' +
      '                        {' +
      '                            \"TypeCode\": \"PROF\",' +
      '                            \"Type\": \"Proof Charge\",' +
      '                            \"Description\": \"Virtual Proof\",' +
      '                            \"Prices\": [' +
      '                                {' +
      '                                    \"Quantity\": {' +
      '                                        \"From\": 1,' +
      '                                        \"To\": 2147483647,' +
      '                                        \"$index\": 1' +
      '                                    },' +
      '                                    \"Price\": 12,' +
      '                                    \"Cost\": 9.6,' +
      '                                    \"DiscountCode\": \"V\",' +
      '                                    \"CurrencyCode\": \"USD\",' +
      '                                    \"IsQUR\": false' +
      '                                }' +
      '                            ],' +
      '                            \"PriceIncludes\": \"no charge for orders of 5,000 units or more.\",' +
      '                            \"UsageLevelCode\": \"PORD\",' +
      '                            \"UsageLevel\": \"Per Order\",' +
      '                            \"IsRequired\": true' +
      '                        }' +
      '                    ]' +
      '                }' +
      '            ]' +
      '        },' +
      '        \"Sizes\": {' +
      '            \"Values\": [' +
      '                {' +
      '                    \"Code\": \"$2HQ\",' +
      '                    \"Name\": \"1 5/8\\\" w  x 5/8\\\" h\",' +
      '                    \"Description\": \"Handle\",' +
      '                    \"$index\": 3' +
      '                },' +
      '                {' +
      '                    \"Code\": \"$2HQ\",' +
      '                    \"Name\": \"2\\\" w x 1\\\" h\",' +
      '                    \"Description\": \"Oval\"' +
      '                }' +
      '            ]' +
      '        },' +
      '        \"Locations\": {' +
      '            \"Values\": [' +
      '                {' +
      '                    \"Name\": \"Handle\",' +
      '                    \"Options\": [' +
      '                        {' +
      '                            \"Type\": \"Imprint Size\",' +
      '                            \"Values\": [' +
      '                                {' +
      '                                    \"Code\": \"$2HQ\",' +
      '                                    \"Name\": \"1 5/8\\\" w  x 5/8\\\" h\",' +
      '                                    \"$index\": 1' +
      '                                }' +
      '                            ]' +
      '                        }' +
      '                    ],' +
      '                    \"$index\": 3' +
      '                },' +
      '                {' +
      '                    \"Name\": \"Oval on Mug\",' +
      '                    \"Description\": \"Oval\",' +
      '                    \"Options\": [' +
      '                        {' +
      '                            \"Type\": \"Imprint Size\",' +
      '                            \"Values\": [' +
      '                                {' +
      '                                    \"Code\": \"$2HQ\",' +
      '                                    \"Name\": \"2\\\" w x 1\\\" h\",' +
      '                                    \"$index\": 1' +
      '                                }' +
      '                            ]' +
      '                        }' +
      '                    ]' +
      '                }' +
      '            ]' +
      '        },' +
      '        \"Options\": [' +
      '            {' +
      '                \"Name\": \"Other Charges\",' +
      '                \"Groups\": [' +
      '                    {' +
      '                        \"Name\": \"Copy Change\",' +
      '                        \"Charges\": [' +
      '                            {' +
      '                                \"TypeCode\": \"CPCH\",' +
      '                                \"Type\": \"Copy Changes Charge\",' +
      '                                \"Description\": \"Copy Change\",' +
      '                                \"Prices\": [' +
      '                                    {' +
      '                                        \"Quantity\": {' +
      '                                            \"From\": 1,' +
      '                                            \"To\": 2147483647,' +
      '                                            \"$index\": 1' +
      '                                        },' +
      '                                        \"Price\": 35,' +
      '                                        \"Cost\": 28,' +
      '                                        \"DiscountCode\": \"V\",' +
      '                                        \"CurrencyCode\": \"USD\",' +
      '                                        \"IsQUR\": false' +
      '                                    }' +
      '                                ],' +
      '                                \"PriceIncludes\": \"minimum catalog quantity for each product applies to each change.\",' +
      '                                \"IsRequired\": true' +
      '                            }' +
      '                        ]' +
      '                    },' +
      '                    {' +
      '                        \"Name\": \"Imprint Color Change\",' +
      '                        \"Charges\": [' +
      '                            {' +
      '                                \"TypeCode\": \"ICCH\",' +
      '                                \"Type\": \"Imprint Color Charge\",' +
      '                                \"Description\": \"Imprint Color Change\",' +
      '                                \"Prices\": [' +
      '                                    {' +
      '                                        \"Quantity\": {' +
      '                                            \"From\": 1,' +
      '                                            \"To\": 2147483647,' +
      '                                            \"$index\": 1' +
      '                                        },' +
      '                                        \"Price\": 35,' +
      '                                        \"Cost\": 28,' +
      '                                        \"DiscountCode\": \"V\",' +
      '                                        \"CurrencyCode\": \"USD\",' +
      '                                        \"IsQUR\": false' +
      '                                    }' +
      '                                ],' +
      '                                \"PriceIncludes\": \"minimum catalog quantity for each product applies to each change.\",' +
      '                                \"IsRequired\": true' +
      '                            }' +
      '                        ]' +
      '                    },' +
      '                    {' +
      '                        \"Name\": \"Typesetting\",' +
      '                        \"Charges\": [' +
      '                            {' +
      '                                \"TypeCode\": \"TSCH\",' +
      '                                \"Type\": \"Typesetting Charge\",' +
      '                                \"Description\": \"Typesetting\",' +
      '                                \"Prices\": [' +
      '                                    {' +
      '                                        \"Quantity\": {' +
      '                                            \"From\": 1,' +
      '                                            \"To\": 2147483647,' +
      '                                            \"$index\": 1' +
      '                                        },' +
      '                                        \"Price\": 12,' +
      '                                        \"Cost\": 9.6,' +
      '                                        \"DiscountCode\": \"V\",' +
      '                                        \"CurrencyCode\": \"USD\",' +
      '                                        \"IsQUR\": false' +
      '                                    }' +
      '                                ],' +
      '                                \"PriceIncludes\": \"for up to 5 lines straight line text. Includes Virtual Proof for customer, to ensure accuracy.\",' +
      '                                \"IsRequired\": true' +
      '                            }' +
      '                        ]' +
      '                    }' +
      '                ]' +
      '            }' +
      '        ],' +
      '        \"FullColorProcess\": true,' +
      '        \"Personalization\": true,' +
      '        \"SoldUnimprinted\": false' +
      '    },' +
      '    \"Packaging\": [' +
      '        {' +
      '            \"Name\": \"Packaging\",' +
      '            \"Charges\": [' +
      '                {' +
      '                    \"TypeCode\": \"PGCH\",' +
      '                    \"Type\": \"Packaging Charge\",' +
      '                    \"Description\": \"Partial carton fee\",' +
      '                    \"Prices\": [' +
      '                        {' +
      '                            \"Quantity\": {' +
      '                                \"From\": 1,' +
      '                                \"To\": 2147483647,' +
      '                                \"$index\": 1' +
      '                            },' +
      '                            \"Price\": 25,' +
      '                            \"Cost\": 20,' +
      '                            \"DiscountCode\": \"V\",' +
      '                            \"CurrencyCode\": \"USD\",' +
      '                            \"IsQUR\": false' +
      '                        }' +
      '                    ],' +
      '                    \"IsRequired\": true' +
      '                }' +
      '            ],' +
      '            \"Values\": [' +
      '                \"Partial carton fee\"' +
      '            ]' +
      '        }' +
      '    ],' +
      '    \"Shipping\": {' +
      '        \"Options\": {' +
      '            \"Values\": [' +
      '                {' +
      '                    \"Name\": \"For USPS postal shipments (shipping cost for one box)\",' +
      '                    \"Charges\": [' +
      '                        {' +
      '                            \"TypeCode\": \"SPCH\",' +
      '                            \"Type\": \"Shipping Charge\",' +
      '                            \"Description\": \"For USPS postal shipments (shipping cost for one box)\",' +
      '                            \"Prices\": [' +
      '                                {' +
      '                                    \"Quantity\": {' +
      '                                        \"From\": 1,' +
      '                                        \"To\": 2147483647,' +
      '                                        \"$index\": 1' +
      '                                    },' +
      '                                    \"Price\": 30,' +
      '                                    \"Cost\": 30,' +
      '                                    \"DiscountCode\": \"Z\",' +
      '                                    \"CurrencyCode\": \"USD\",' +
      '                                    \"IsQUR\": false' +
      '                                }' +
      '                            ],' +
      '                            \"IsRequired\": true' +
      '                        }' +
      '                    ],' +
      '                    \"$index\": 3' +
      '                },' +
      '                {' +
      '                    \"Name\": \"Handling Fee\",' +
      '                    \"Charges\": [' +
      '                        {' +
      '                            \"TypeCode\": \"SPCH\",' +
      '                            \"Type\": \"Shipping Charge\",' +
      '                            \"Description\": \"Handling Fee\",' +
      '                            \"Prices\": [' +
      '                                {' +
      '                                    \"Quantity\": {' +
      '                                        \"From\": 1,' +
      '                                        \"To\": 2147483647,' +
      '                                        \"$index\": 1' +
      '                                    },' +
      '                                    \"Price\": 3.5,' +
      '                                    \"Cost\": 3.5,' +
      '                                    \"DiscountCode\": \"Z\",' +
      '                                    \"CurrencyCode\": \"USD\",' +
      '                                    \"IsQUR\": false' +
      '                                }' +
      '                            ],' +
      '                            \"PriceIncludes\": \"per box\",' +
      '                            \"IsRequired\": true' +
      '                        }' +
      '                    ]' +
      '                },' +
      '                {' +
      '                    \"Name\": \"Pallet Charge\",' +
      '                    \"Charges\": [' +
      '                        {' +
      '                            \"TypeCode\": \"SPCH\",' +
      '                            \"Type\": \"Shipping Charge\",' +
      '                            \"Description\": \"Pallet Charge\",' +
      '                            \"Prices\": [' +
      '                                {' +
      '                                    \"Quantity\": {' +
      '                                        \"From\": 1,' +
      '                                        \"To\": 2147483647,' +
      '                                        \"$index\": 1' +
      '                                    },' +
      '                                    \"Price\": 25,' +
      '                                    \"Cost\": 25,' +
      '                                    \"DiscountCode\": \"Z\",' +
      '                                    \"CurrencyCode\": \"USD\",' +
      '                                    \"IsQUR\": false' +
      '                                }' +
      '                            ],' +
      '                            \"PriceIncludes\": \"per pallet\",' +
      '                            \"IsRequired\": true' +
      '                        }' +
      '                    ]' +
      '                },' +
      '                {' +
      '                    \"Name\": \"For each additional box\",' +
      '                    \"Charges\": [' +
      '                        {' +
      '                            \"TypeCode\": \"SPCH\",' +
      '                            \"Type\": \"Shipping Charge\",' +
      '                            \"Description\": \"For each additional box\",' +
      '                            \"Prices\": [' +
      '                                {' +
      '                                    \"Quantity\": {' +
      '                                        \"From\": 1,' +
      '                                        \"To\": 2147483647,' +
      '                                        \"$index\": 1' +
      '                                    },' +
      '                                    \"Price\": 10,' +
      '                                    \"Cost\": 10,' +
      '                                    \"DiscountCode\": \"Z\",' +
      '                                    \"CurrencyCode\": \"USD\",' +
      '                                    \"IsQUR\": false' +
      '                                }' +
      '                            ],' +
      '                            \"IsRequired\": true' +
      '                        }' +
      '                    ]' +
      '                },' +
      '                {' +
      '                    \"Name\": \"Split Shipments\",' +
      '                    \"Charges\": [' +
      '                        {' +
      '                            \"TypeCode\": \"SPCH\",' +
      '                            \"Type\": \"Shipping Charge\",' +
      '                            \"Description\": \"Split Shipments\",' +
      '                            \"Prices\": [' +
      '                                {' +
      '                                    \"Quantity\": {' +
      '                                        \"From\": 1,' +
      '                                        \"To\": 2147483647,' +
      '                                        \"$index\": 1' +
      '                                    },' +
      '                                    \"Price\": 12.5,' +
      '                                    \"Cost\": 10,' +
      '                                    \"DiscountCode\": \"V\",' +
      '                                    \"CurrencyCode\": \"USD\",' +
      '                                    \"IsQUR\": false' +
      '                                }' +
      '                            ],' +
      '                            \"PriceIncludes\": \"per address\",' +
      '                            \"IsRequired\": true' +
      '                        }' +
      '                    ]' +
      '                }' +
      '            ]' +
      '        },' +
      '        \"PackageUnit\": \"Carton\",' +
      '        \"ItemsPerPackage\": 48,' +
      '        \"BillsByWeight\": false,' +
      '        \"BillsBySize\": false,' +
      '        \"PackageInPlainBox\": false' +
      '    },' +
      '    \"VariantId\": 0,' +
      '    \"Warnings\": [' +
      '        {' +
      '            \"Name\": \"\",' +
      '            \"Description\": \"No safety warnings for this product\",' +
      '            \"Warning\": \"No safety warnings for this product\",' +
      '            \"Type\": \"SWCH\"' +
      '        }' +
      '    ],' +
      '    \"Currency\": \"USD\",' +
      '    \"Currencies\": [' +
      '        \"USD\"' +
      '    ],' +
      '    \"Prices\": [' +
      '        {' +
      '            \"Quantity\": {' +
      '                \"From\": 72,' +
      '                \"To\": 143,' +
      '                \"$index\": 1' +
      '            },' +
      '            \"Price\": 6.78,' +
      '            \"Cost\": 4.068,' +
      '            \"DiscountCode\": \"R\",' +
      '            \"CurrencyCode\": \"USD\",' +
      '            \"IsQUR\": false' +
      '        },' +
      '        {' +
      '            \"Quantity\": {' +
      '                \"From\": 144,' +
      '                \"To\": 299,' +
      '                \"$index\": 1' +
      '            },' +
      '            \"Price\": 6.69,' +
      '            \"Cost\": 4.014,' +
      '            \"DiscountCode\": \"R\",' +
      '            \"CurrencyCode\": \"USD\",' +
      '            \"IsQUR\": false' +
      '        },' +
      '        {' +
      '            \"Quantity\": {' +
      '                \"From\": 300,' +
      '                \"To\": 499,' +
      '                \"$index\": 1' +
      '            },' +
      '            \"Price\": 6.59,' +
      '            \"Cost\": 3.954,' +
      '            \"DiscountCode\": \"R\",' +
      '            \"CurrencyCode\": \"USD\",' +
      '            \"IsQUR\": false' +
      '        },' +
      '        {' +
      '            \"Quantity\": {' +
      '                \"From\": 500,' +
      '                \"To\": 2147483647,' +
      '                \"$index\": 1' +
      '            },' +
      '            \"Price\": 6.49,' +
      '            \"Cost\": 3.894,' +
      '            \"DiscountCode\": \"R\",' +
      '            \"CurrencyCode\": \"USD\",' +
      '            \"IsQUR\": false' +
      '        }' +
      '    ],' +
      '    \"PriceIncludes\": \"VibraColor(R) Epoxy Resin Domes on the side and the handle\",' +
      '    \"LowestPrice\": {' +
      '        \"Quantity\": {' +
      '            \"From\": 500,' +
      '            \"To\": 2147483647,' +
      '            \"$index\": 1' +
      '        },' +
      '        \"Price\": 6.49,' +
      '        \"Cost\": 3.894,' +
      '        \"DiscountCode\": \"R\",' +
      '        \"CurrencyCode\": \"USD\",' +
      '        \"IsQUR\": false' +
      '    },' +
      '    \"HighestPrice\": {' +
      '        \"Quantity\": {' +
      '            \"From\": 72,' +
      '            \"To\": 143,' +
      '            \"$index\": 1' +
      '        },' +
      '        \"Price\": 6.78,' +
      '        \"Cost\": 4.068,' +
      '        \"DiscountCode\": \"R\",' +
      '        \"CurrencyCode\": \"USD\",' +
      '        \"IsQUR\": false' +
      '    },' +
      '    \"IsNew\": false,' +
      '    \"IsConfirmed\": false,' +
      '    \"HasFullColorProcess\": true,' +
      '    \"HasRushService\": false,' +
      '    \"AdditionalInfo\": \"All orders are subject to a 5% to 7% under/overrun and will be shipped and billed accordingly. A larger overrun may be required for multi-color/location imprints.\\nWe may resize imprints proportionally to maximum imprint area, and we reserve the right to break lines and arrange copy for best appearance, unless otherwise instructed.\",' +
      '    \"UpdateDate\": \"2016-02-09T07:18:13.000-05:00\",' +
      '    \"RequiresConfiguration\": false,' +
      '    \"Values\": [' +
      '        {' +
      '            \"Id\": 68650109,' +
      '            \"Name\": \"Color\",' +
      '            \"Description\": \"Product Color\",' +
      '            \"Code\": \"PRCL\",' +
      '            \"Values\": [' +
      '                {' +
      '                    \"Id\": 753466504,' +
      '                    \"Name\": \"Stainless Steel-Black\",' +
      '                    \"IsSelected\": false' +
      '                }' +
      '            ],' +
      '            \"IsRequired\": false,' +
      '            \"IsMultiSelect\": false' +
      '        },' +
      '        {' +
      '            \"Id\": 68650119,' +
      '            \"Name\": \"Material\",' +
      '            \"Description\": \"Material\",' +
      '            \"Code\": \"MTRL\",' +
      '            \"Values\": [' +
      '                {' +
      '                    \"Id\": 126732865,' +
      '                    \"Name\": \"Stainless Steel\",' +
      '                    \"IsSelected\": false' +
      '                }' +
      '            ],' +
      '            \"IsRequired\": false,' +
      '            \"IsMultiSelect\": false' +
      '        },' +
      '        {' +
      '            \"Id\": 768947154,' +
      '            \"Name\": \"Size\",' +
      '            \"Description\": \"Size\",' +
      '            \"Code\": \"SIZE\",' +
      '            \"Values\": [' +
      '                {' +
      '                    \"Id\": 752975611,' +
      '                    \"Name\": \"12 oz\",' +
      '                    \"IsSelected\": false' +
      '                }' +
      '            ],' +
      '            \"IsRequired\": false,' +
      '            \"IsMultiSelect\": false' +
      '        }' +
      '    ],' +
      '    \"Certifications\": [' +
      '        {' +
      '            \"Id\": 0,' +
      '            \"Name\": \"CPSIA\",' +
      '            \"Code\": \"NOTE\"' +
      '        }' +
      '    ]' +
      '}';
    ESPProduct espProductObj2 = new ESPProduct();
    espProductObj2.parse(json, '');
    String jsonData = '{"Id":550396415,"Name":"Badger Camo T-Shirt","Description":"Add something different to your t-shirt drawer! Our Badger Camo Short Sleeve T-Shirt is made of 100% sublimated polyester and features moisture-management and anti-microbial properties, badger sport paneled shoulder for maximum movement, self-fabric collar, double-needle stitched hem with tack and badger heat seal logo on left sleeve. Available in bold colors and a variety of sizes, this terrific top will stand out!","ShortDescription":"Badger Camo Short Sleeve T-Shirt, blank.","Number":"4181","Numbers":["4181"],"ImageUrl":"media/33807255","Images":["media/33807255","media/31280153","media/31280154","media/31280155","media/31280156","media/31280157","media/31280158","media/31280159","media/31280160","media/31280161","media/31280162","media/31280163","media/31280164","media/31280165","media/31280166","media/31280167","media/31280168","media/31280169","media/31280170","media/31280171","media/31280172","media/31280173","media/31280174","media/31280175","media/31280176","media/31280177","media/31280178","media/31280179","media/31280180","media/31280181","media/31280182","media/31280183","media/31280184","media/31280185","media/31280186","media/31280187","media/31280188","media/31280189","media/31280190","media/31280191","media/31280192","media/31280193","media/31280194"],"Supplier":{"Id":3112,"Name":"S \u0026 S Activewear","AsiNumber":"84358","Phone":{"Work":"(630) 679-9940","TollFree":"(800) 523-2155","Primary":"(630) 679-9940","$index":1},"Fax":{"Work":"(630) 679-9941","Primary":"(630) 679-9941","$index":1},"Email":"info@ssactivewear.com","Websites":["https://www.ssactivewear.com/"],"Rating":{"Rating":10,"Companies":12,"Transactions":229},"MarketingPolicy":"Supplier indicates they sell advertising specialties exclusively through distributors and/or incentive resellers","HasNotes":false,"IsMinorityOwned":false,"IsQcaCertified":false,"IsUnionAvailable":true},"Catalog":{"Id":235398,"Name":"2020 S \u0026 S Activewear","Year":"2020","Asset":"ASI/84358 2020 S and S Activewear","CompanyId":0,"ProductCount":0,"EndUserSafe":false},"Catalogs":[{"Id":235398,"Name":"2020 S \u0026 S Activewear","Year":"2020","Asset":"ASI/84358 2020 S and S Activewear","CompanyId":0,"ProductCount":0,"EndUserSafe":false}],"Categories":[{"Id":"A03228003","Name":"Antimicrobial Enhanced Products"},{"Id":"P03110003","Name":"Performance Apparel"},{"Id":"T00253003","Name":"Unisex","Parent":{"Id":"T00250003","Name":"T-shirts"}}],"Themes":["Hunting"],"TradeNames":["Badger"],"Attributes":{"Colors":{"Values":[{"Code":"DLHF","Name":"Black","ImageUrl":"media/31280153","VendorCode":"50","SKU":"B14285502","$index":3},{"Code":"DROG","Name":"Burnt Orange","ImageUrl":"media/31280156","VendorCode":"66","SKU":"B14285662"},{"Code":"MEBL","Name":"Columbia Blue","ImageUrl":"media/31280159","VendorCode":"26","SKU":"B14285262"},{"Code":"DRGN","Name":"Forest","ImageUrl":"media/31280162","VendorCode":"54","SKU":"B14285542"},{"Code":"DRYE","Name":"Gold","ImageUrl":"media/31280165","VendorCode":"12","SKU":"B14285122"},{"Code":"FLGN","Name":"Lime","ImageUrl":"media/31280168","VendorCode":"16","SKU":"B14285162"},{"Code":"DRRD","Name":"Maroon","ImageUrl":"media/31280171","VendorCode":"53","SKU":"B14285532"},{"Code":"DRBL","Name":"Navy","ImageUrl":"media/31280174","VendorCode":"65","SKU":"B14285652"},{"Code":"FGRI","Name":"OD Green","ImageUrl":"media/31280177","VendorCode":"19","SKU":"B14285192"},{"Code":"MEPL","Name":"Purple","ImageUrl":"media/31280180","VendorCode":"67","SKU":"B14285672"},{"Code":"MERD","Name":"Red","ImageUrl":"media/31280183","VendorCode":"70","SKU":"B14285702"},{"Code":"FLBL","Name":"Royal","ImageUrl":"media/31280186","VendorCode":"75","SKU":"B14285752"},{"Code":"LIBR","Name":"Sand","ImageUrl":"media/31280189","VendorCode":"73","SKU":"B14285732"},{"Code":"ETWF","Name":"White","ImageUrl":"media/31280192","VendorCode":"00","SKU":"B14285002"}]},"Sizes":{"Values":[{"Code":"AZCW","Name":"XS","Options":[{"Type":"Color","Values":[{"Code":"DLHF","Name":"Black","ImageUrl":"media/31280153","VendorCode":"50","$index":1},{"Code":"DROG","Name":"Burnt Orange","ImageUrl":"media/31280156","VendorCode":"66"},{"Code":"MEBL","Name":"Columbia Blue","ImageUrl":"media/31280159","VendorCode":"26"},{"Code":"DRGN","Name":"Forest","ImageUrl":"media/31280162","VendorCode":"54"},{"Code":"DRYE","Name":"Gold","ImageUrl":"media/31280165","VendorCode":"12"},{"Code":"FLGN","Name":"Lime","ImageUrl":"media/31280168","VendorCode":"16"},{"Code":"DRRD","Name":"Maroon","ImageUrl":"media/31280171","VendorCode":"53"},{"Code":"DRBL","Name":"Navy","ImageUrl":"media/31280174","VendorCode":"65"},{"Code":"FGRI","Name":"OD Green","ImageUrl":"media/31280177","VendorCode":"19"},{"Code":"MEPL","Name":"Purple","ImageUrl":"media/31280180","VendorCode":"67"},{"Code":"MERD","Name":"Red","ImageUrl":"media/31280183","VendorCode":"70"},{"Code":"FLBL","Name":"Royal","ImageUrl":"media/31280186","VendorCode":"75"},{"Code":"LIBR","Name":"Sand","ImageUrl":"media/31280189","VendorCode":"73"},{"Code":"ETWF","Name":"White","ImageUrl":"media/31280192","VendorCode":"00"}]}],"VendorCode":"2","SKU":"B14285502","$index":3},{"Code":"AZCW","Name":"S","Options":[{"Type":"Color","Values":[{"Code":"DLHF","Name":"Black","ImageUrl":"media/31280153","VendorCode":"50","$index":1},{"Code":"DROG","Name":"Burnt Orange","ImageUrl":"media/31280156","VendorCode":"66"},{"Code":"MEBL","Name":"Columbia Blue","ImageUrl":"media/31280159","VendorCode":"26"},{"Code":"DRGN","Name":"Forest","ImageUrl":"media/31280162","VendorCode":"54"},{"Code":"DRYE","Name":"Gold","ImageUrl":"media/31280165","VendorCode":"12"},{"Code":"FLGN","Name":"Lime","ImageUrl":"media/31280168","VendorCode":"16"},{"Code":"DRRD","Name":"Maroon","ImageUrl":"media/31280171","VendorCode":"53"},{"Code":"DRBL","Name":"Navy","ImageUrl":"media/31280174","VendorCode":"65"},{"Code":"FGRI","Name":"OD Green","ImageUrl":"media/31280177","VendorCode":"19"},{"Code":"MEPL","Name":"Purple","ImageUrl":"media/31280180","VendorCode":"67"},{"Code":"MERD","Name":"Red","ImageUrl":"media/31280183","VendorCode":"70"},{"Code":"FLBL","Name":"Royal","ImageUrl":"media/31280186","VendorCode":"75"},{"Code":"LIBR","Name":"Sand","ImageUrl":"media/31280189","VendorCode":"73"},{"Code":"ETWF","Name":"White","ImageUrl":"media/31280192","VendorCode":"00"}]}],"VendorCode":"3","SKU":"B14285503"},{"Code":"AZCW","Name":"M","Options":[{"Type":"Color","Values":[{"Code":"DLHF","Name":"Black","ImageUrl":"media/31280153","VendorCode":"50","$index":1},{"Code":"DROG","Name":"Burnt Orange","ImageUrl":"media/31280156","VendorCode":"66"},{"Code":"MEBL","Name":"Columbia Blue","ImageUrl":"media/31280159","VendorCode":"26"},{"Code":"DRGN","Name":"Forest","ImageUrl":"media/31280162","VendorCode":"54"},{"Code":"DRYE","Name":"Gold","ImageUrl":"media/31280165","VendorCode":"12"},{"Code":"FLGN","Name":"Lime","ImageUrl":"media/31280168","VendorCode":"16"},{"Code":"DRRD","Name":"Maroon","ImageUrl":"media/31280171","VendorCode":"53"},{"Code":"DRBL","Name":"Navy","ImageUrl":"media/31280174","VendorCode":"65"},{"Code":"FGRI","Name":"OD Green","ImageUrl":"media/31280177","VendorCode":"19"},{"Code":"MEPL","Name":"Purple","ImageUrl":"media/31280180","VendorCode":"67"},{"Code":"MERD","Name":"Red","ImageUrl":"media/31280183","VendorCode":"70"},{"Code":"FLBL","Name":"Royal","ImageUrl":"media/31280186","VendorCode":"75"},{"Code":"LIBR","Name":"Sand","ImageUrl":"media/31280189","VendorCode":"73"},{"Code":"ETWF","Name":"White","ImageUrl":"media/31280192","VendorCode":"00"}]}],"VendorCode":"4","SKU":"B14285504"},{"Code":"AZCW","Name":"L","Options":[{"Type":"Color","Values":[{"Code":"DLHF","Name":"Black","ImageUrl":"media/31280153","VendorCode":"50","$index":1},{"Code":"DROG","Name":"Burnt Orange","ImageUrl":"media/31280156","VendorCode":"66"},{"Code":"MEBL","Name":"Columbia Blue","ImageUrl":"media/31280159","VendorCode":"26"},{"Code":"DRGN","Name":"Forest","ImageUrl":"media/31280162","VendorCode":"54"},{"Code":"DRYE","Name":"Gold","ImageUrl":"media/31280165","VendorCode":"12"},{"Code":"FLGN","Name":"Lime","ImageUrl":"media/31280168","VendorCode":"16"},{"Code":"DRRD","Name":"Maroon","ImageUrl":"media/31280171","VendorCode":"53"},{"Code":"DRBL","Name":"Navy","ImageUrl":"media/31280174","VendorCode":"65"},{"Code":"FGRI","Name":"OD Green","ImageUrl":"media/31280177","VendorCode":"19"},{"Code":"MEPL","Name":"Purple","ImageUrl":"media/31280180","VendorCode":"67"},{"Code":"MERD","Name":"Red","ImageUrl":"media/31280183","VendorCode":"70"},{"Code":"FLBL","Name":"Royal","ImageUrl":"media/31280186","VendorCode":"75"},{"Code":"LIBR","Name":"Sand","ImageUrl":"media/31280189","VendorCode":"73"},{"Code":"ETWF","Name":"White","ImageUrl":"media/31280192","VendorCode":"00"}]}],"VendorCode":"5","SKU":"B14285505"},{"Code":"AZCW","Name":"XL","Options":[{"Type":"Color","Values":[{"Code":"DLHF","Name":"Black","ImageUrl":"media/31280153","VendorCode":"50","$index":1},{"Code":"DROG","Name":"Burnt Orange","ImageUrl":"media/31280156","VendorCode":"66"},{"Code":"MEBL","Name":"Columbia Blue","ImageUrl":"media/31280159","VendorCode":"26"},{"Code":"DRGN","Name":"Forest","ImageUrl":"media/31280162","VendorCode":"54"},{"Code":"DRYE","Name":"Gold","ImageUrl":"media/31280165","VendorCode":"12"},{"Code":"FLGN","Name":"Lime","ImageUrl":"media/31280168","VendorCode":"16"},{"Code":"DRRD","Name":"Maroon","ImageUrl":"media/31280171","VendorCode":"53"},{"Code":"DRBL","Name":"Navy","ImageUrl":"media/31280174","VendorCode":"65"},{"Code":"FGRI","Name":"OD Green","ImageUrl":"media/31280177","VendorCode":"19"},{"Code":"MEPL","Name":"Purple","ImageUrl":"media/31280180","VendorCode":"67"},{"Code":"MERD","Name":"Red","ImageUrl":"media/31280183","VendorCode":"70"},{"Code":"FLBL","Name":"Royal","ImageUrl":"media/31280186","VendorCode":"75"},{"Code":"LIBR","Name":"Sand","ImageUrl":"media/31280189","VendorCode":"73"},{"Code":"ETWF","Name":"White","ImageUrl":"media/31280192","VendorCode":"00"}]}],"VendorCode":"6","SKU":"B14285506"},{"Code":"BBOB","Name":"2XL","Options":[{"Type":"Color","Values":[{"Code":"DLHF","Name":"Black","ImageUrl":"media/31280153","VendorCode":"50","$index":1},{"Code":"DROG","Name":"Burnt Orange","ImageUrl":"media/31280156","VendorCode":"66"},{"Code":"MEBL","Name":"Columbia Blue","ImageUrl":"media/31280159","VendorCode":"26"},{"Code":"DRGN","Name":"Forest","ImageUrl":"media/31280162","VendorCode":"54"},{"Code":"DRYE","Name":"Gold","ImageUrl":"media/31280165","VendorCode":"12"},{"Code":"FLGN","Name":"Lime","ImageUrl":"media/31280168","VendorCode":"16"},{"Code":"DRRD","Name":"Maroon","ImageUrl":"media/31280171","VendorCode":"53"},{"Code":"DRBL","Name":"Navy","ImageUrl":"media/31280174","VendorCode":"65"},{"Code":"FGRI","Name":"OD Green","ImageUrl":"media/31280177","VendorCode":"19"},{"Code":"MEPL","Name":"Purple","ImageUrl":"media/31280180","VendorCode":"67"},{"Code":"MERD","Name":"Red","ImageUrl":"media/31280183","VendorCode":"70"},{"Code":"FLBL","Name":"Royal","ImageUrl":"media/31280186","VendorCode":"75"},{"Code":"LIBR","Name":"Sand","ImageUrl":"media/31280189","VendorCode":"73"},{"Code":"ETWF","Name":"White","ImageUrl":"media/31280192","VendorCode":"00"}]}],"VendorCode":"7","SKU":"B14285507"},{"Code":"BBOB","Name":"3XL","Options":[{"Type":"Color","Values":[{"Code":"DLHF","Name":"Black","ImageUrl":"media/31280153","VendorCode":"50","$index":1},{"Code":"DROG","Name":"Burnt Orange","ImageUrl":"media/31280156","VendorCode":"66"},{"Code":"MEBL","Name":"Columbia Blue","ImageUrl":"media/31280159","VendorCode":"26"},{"Code":"DRGN","Name":"Forest","ImageUrl":"media/31280162","VendorCode":"54"},{"Code":"DRYE","Name":"Gold","ImageUrl":"media/31280165","VendorCode":"12"},{"Code":"FLGN","Name":"Lime","ImageUrl":"media/31280168","VendorCode":"16"},{"Code":"DRRD","Name":"Maroon","ImageUrl":"media/31280171","VendorCode":"53"},{"Code":"DRBL","Name":"Navy","ImageUrl":"media/31280174","VendorCode":"65"},{"Code":"FGRI","Name":"OD Green","ImageUrl":"media/31280177","VendorCode":"19"},{"Code":"MEPL","Name":"Purple","ImageUrl":"media/31280180","VendorCode":"67"},{"Code":"MERD","Name":"Red","ImageUrl":"media/31280183","VendorCode":"70"},{"Code":"FLBL","Name":"Royal","ImageUrl":"media/31280186","VendorCode":"75"},{"Code":"LIBR","Name":"Sand","ImageUrl":"media/31280189","VendorCode":"73"},{"Code":"ETWF","Name":"White","ImageUrl":"media/31280192","VendorCode":"00"}]}],"VendorCode":"8","SKU":"B14285508"},{"Code":"BBOB","Name":"4XL","Options":[{"Type":"Color","Values":[{"Code":"DLHF","Name":"Black","ImageUrl":"media/31280153","VendorCode":"50","$index":1},{"Code":"DROG","Name":"Burnt Orange","ImageUrl":"media/31280156","VendorCode":"66"},{"Code":"MEBL","Name":"Columbia Blue","ImageUrl":"media/31280159","VendorCode":"26"},{"Code":"DRGN","Name":"Forest","ImageUrl":"media/31280162","VendorCode":"54"},{"Code":"DRYE","Name":"Gold","ImageUrl":"media/31280165","VendorCode":"12"},{"Code":"FLGN","Name":"Lime","ImageUrl":"media/31280168","VendorCode":"16"},{"Code":"DRRD","Name":"Maroon","ImageUrl":"media/31280171","VendorCode":"53"},{"Code":"DRBL","Name":"Navy","ImageUrl":"media/31280174","VendorCode":"65"},{"Code":"FGRI","Name":"OD Green","ImageUrl":"media/31280177","VendorCode":"19"},{"Code":"MEPL","Name":"Purple","ImageUrl":"media/31280180","VendorCode":"67"},{"Code":"MERD","Name":"Red","ImageUrl":"media/31280183","VendorCode":"70"},{"Code":"FLBL","Name":"Royal","ImageUrl":"media/31280186","VendorCode":"75"},{"Code":"LIBR","Name":"Sand","ImageUrl":"media/31280189","VendorCode":"73"},{"Code":"ETWF","Name":"White","ImageUrl":"media/31280192","VendorCode":"00"}]}],"VendorCode":"9","SKU":"B14285509"}]},"Materials":{"Values":[{"Code":"$02B","Name":"Polyester","$index":3}]}},"Imprinting":{"Methods":{"Values":[{"Code":"$UNI","Name":"UNIMPRINTED","$index":3}]},"FullColorProcess":false,"Personalization":false,"SoldUnimprinted":true},"Variants":[{"Id":840880292,"Name":"XS,S,M,L,XL,Burnt Orange,Columbia Blue,Forest,Gold,Lime,Maroon,Navy,OD Green,Purple,Red,Royal,San...","Description":"Size: XS, Size: S, Size: M, Size: L, Size: XL","ImageUrl":"media/31280153","Attributes":{"Colors":{"Values":[{"Code":"DLHF","Name":"Black","ImageUrl":"media/31280153","VendorCode":"50","SKU":"B14285502","$index":3},{"Code":"DROG","Name":"Burnt Orange","ImageUrl":"media/31280156","VendorCode":"66","SKU":"B14285662"},{"Code":"MEBL","Name":"Columbia Blue","ImageUrl":"media/31280159","VendorCode":"26","SKU":"B14285262"},{"Code":"DRGN","Name":"Forest","ImageUrl":"media/31280162","VendorCode":"54","SKU":"B14285542"},{"Code":"DRYE","Name":"Gold","ImageUrl":"media/31280165","VendorCode":"12","SKU":"B14285122"},{"Code":"FLGN","Name":"Lime","ImageUrl":"media/31280168","VendorCode":"16","SKU":"B14285162"},{"Code":"DRRD","Name":"Maroon","ImageUrl":"media/31280171","VendorCode":"53","SKU":"B14285532"},{"Code":"DRBL","Name":"Navy","ImageUrl":"media/31280174","VendorCode":"65","SKU":"B14285652"},{"Code":"FGRI","Name":"OD Green","ImageUrl":"media/31280177","VendorCode":"19","SKU":"B14285192"},{"Code":"MEPL","Name":"Purple","ImageUrl":"media/31280180","VendorCode":"67","SKU":"B14285672"},{"Code":"MERD","Name":"Red","ImageUrl":"media/31280183","VendorCode":"70","SKU":"B14285702"},{"Code":"FLBL","Name":"Royal","ImageUrl":"media/31280186","VendorCode":"75","SKU":"B14285752"},{"Code":"LIBR","Name":"Sand","ImageUrl":"media/31280189","VendorCode":"73","SKU":"B14285732"},{"Code":"ETWF","Name":"White","ImageUrl":"media/31280192","VendorCode":"00","SKU":"B14285002"}]},"Sizes":{"Values":[{"Code":"AZCW","Name":"XS","Options":[{"Type":"Color","Values":[{"Code":"DLHF","Name":"Black","ImageUrl":"media/31280153","VendorCode":"50","$index":1},{"Code":"DROG","Name":"Burnt Orange","ImageUrl":"media/31280156","VendorCode":"66"},{"Code":"MEBL","Name":"Columbia Blue","ImageUrl":"media/31280159","VendorCode":"26"},{"Code":"DRGN","Name":"Forest","ImageUrl":"media/31280162","VendorCode":"54"},{"Code":"DRYE","Name":"Gold","ImageUrl":"media/31280165","VendorCode":"12"},{"Code":"FLGN","Name":"Lime","ImageUrl":"media/31280168","VendorCode":"16"},{"Code":"DRRD","Name":"Maroon","ImageUrl":"media/31280171","VendorCode":"53"},{"Code":"DRBL","Name":"Navy","ImageUrl":"media/31280174","VendorCode":"65"},{"Code":"FGRI","Name":"OD Green","ImageUrl":"media/31280177","VendorCode":"19"},{"Code":"MEPL","Name":"Purple","ImageUrl":"media/31280180","VendorCode":"67"},{"Code":"MERD","Name":"Red","ImageUrl":"media/31280183","VendorCode":"70"},{"Code":"FLBL","Name":"Royal","ImageUrl":"media/31280186","VendorCode":"75"},{"Code":"LIBR","Name":"Sand","ImageUrl":"media/31280189","VendorCode":"73"},{"Code":"ETWF","Name":"White","ImageUrl":"media/31280192","VendorCode":"00"}]}],"VendorCode":"2","SKU":"B14285502","$index":3},{"Code":"AZCW","Name":"S","Options":[{"Type":"Color","Values":[{"Code":"DLHF","Name":"Black","ImageUrl":"media/31280153","VendorCode":"50","$index":1},{"Code":"DROG","Name":"Burnt Orange","ImageUrl":"media/31280156","VendorCode":"66"},{"Code":"MEBL","Name":"Columbia Blue","ImageUrl":"media/31280159","VendorCode":"26"},{"Code":"DRGN","Name":"Forest","ImageUrl":"media/31280162","VendorCode":"54"},{"Code":"DRYE","Name":"Gold","ImageUrl":"media/31280165","VendorCode":"12"},{"Code":"FLGN","Name":"Lime","ImageUrl":"media/31280168","VendorCode":"16"},{"Code":"DRRD","Name":"Maroon","ImageUrl":"media/31280171","VendorCode":"53"},{"Code":"DRBL","Name":"Navy","ImageUrl":"media/31280174","VendorCode":"65"},{"Code":"FGRI","Name":"OD Green","ImageUrl":"media/31280177","VendorCode":"19"},{"Code":"MEPL","Name":"Purple","ImageUrl":"media/31280180","VendorCode":"67"},{"Code":"MERD","Name":"Red","ImageUrl":"media/31280183","VendorCode":"70"},{"Code":"FLBL","Name":"Royal","ImageUrl":"media/31280186","VendorCode":"75"},{"Code":"LIBR","Name":"Sand","ImageUrl":"media/31280189","VendorCode":"73"},{"Code":"ETWF","Name":"White","ImageUrl":"media/31280192","VendorCode":"00"}]}],"VendorCode":"3","SKU":"B14285503"},{"Code":"AZCW","Name":"M","Options":[{"Type":"Color","Values":[{"Code":"DLHF","Name":"Black","ImageUrl":"media/31280153","VendorCode":"50","$index":1},{"Code":"DROG","Name":"Burnt Orange","ImageUrl":"media/31280156","VendorCode":"66"},{"Code":"MEBL","Name":"Columbia Blue","ImageUrl":"media/31280159","VendorCode":"26"},{"Code":"DRGN","Name":"Forest","ImageUrl":"media/31280162","VendorCode":"54"},{"Code":"DRYE","Name":"Gold","ImageUrl":"media/31280165","VendorCode":"12"},{"Code":"FLGN","Name":"Lime","ImageUrl":"media/31280168","VendorCode":"16"},{"Code":"DRRD","Name":"Maroon","ImageUrl":"media/31280171","VendorCode":"53"},{"Code":"DRBL","Name":"Navy","ImageUrl":"media/31280174","VendorCode":"65"},{"Code":"FGRI","Name":"OD Green","ImageUrl":"media/31280177","VendorCode":"19"},{"Code":"MEPL","Name":"Purple","ImageUrl":"media/31280180","VendorCode":"67"},{"Code":"MERD","Name":"Red","ImageUrl":"media/31280183","VendorCode":"70"},{"Code":"FLBL","Name":"Royal","ImageUrl":"media/31280186","VendorCode":"75"},{"Code":"LIBR","Name":"Sand","ImageUrl":"media/31280189","VendorCode":"73"},{"Code":"ETWF","Name":"White","ImageUrl":"media/31280192","VendorCode":"00"}]}],"VendorCode":"4","SKU":"B14285504"},{"Code":"AZCW","Name":"L","Options":[{"Type":"Color","Values":[{"Code":"DLHF","Name":"Black","ImageUrl":"media/31280153","VendorCode":"50","$index":1},{"Code":"DROG","Name":"Burnt Orange","ImageUrl":"media/31280156","VendorCode":"66"},{"Code":"MEBL","Name":"Columbia Blue","ImageUrl":"media/31280159","VendorCode":"26"},{"Code":"DRGN","Name":"Forest","ImageUrl":"media/31280162","VendorCode":"54"},{"Code":"DRYE","Name":"Gold","ImageUrl":"media/31280165","VendorCode":"12"},{"Code":"FLGN","Name":"Lime","ImageUrl":"media/31280168","VendorCode":"16"},{"Code":"DRRD","Name":"Maroon","ImageUrl":"media/31280171","VendorCode":"53"},{"Code":"DRBL","Name":"Navy","ImageUrl":"media/31280174","VendorCode":"65"},{"Code":"FGRI","Name":"OD Green","ImageUrl":"media/31280177","VendorCode":"19"},{"Code":"MEPL","Name":"Purple","ImageUrl":"media/31280180","VendorCode":"67"},{"Code":"MERD","Name":"Red","ImageUrl":"media/31280183","VendorCode":"70"},{"Code":"FLBL","Name":"Royal","ImageUrl":"media/31280186","VendorCode":"75"},{"Code":"LIBR","Name":"Sand","ImageUrl":"media/31280189","VendorCode":"73"},{"Code":"ETWF","Name":"White","ImageUrl":"media/31280192","VendorCode":"00"}]}],"VendorCode":"5","SKU":"B14285505"},{"Code":"AZCW","Name":"XL","Options":[{"Type":"Color","Values":[{"Code":"DLHF","Name":"Black","ImageUrl":"media/31280153","VendorCode":"50","$index":1},{"Code":"DROG","Name":"Burnt Orange","ImageUrl":"media/31280156","VendorCode":"66"},{"Code":"MEBL","Name":"Columbia Blue","ImageUrl":"media/31280159","VendorCode":"26"},{"Code":"DRGN","Name":"Forest","ImageUrl":"media/31280162","VendorCode":"54"},{"Code":"DRYE","Name":"Gold","ImageUrl":"media/31280165","VendorCode":"12"},{"Code":"FLGN","Name":"Lime","ImageUrl":"media/31280168","VendorCode":"16"},{"Code":"DRRD","Name":"Maroon","ImageUrl":"media/31280171","VendorCode":"53"},{"Code":"DRBL","Name":"Navy","ImageUrl":"media/31280174","VendorCode":"65"},{"Code":"FGRI","Name":"OD Green","ImageUrl":"media/31280177","VendorCode":"19"},{"Code":"MEPL","Name":"Purple","ImageUrl":"media/31280180","VendorCode":"67"},{"Code":"MERD","Name":"Red","ImageUrl":"media/31280183","VendorCode":"70"},{"Code":"FLBL","Name":"Royal","ImageUrl":"media/31280186","VendorCode":"75"},{"Code":"LIBR","Name":"Sand","ImageUrl":"media/31280189","VendorCode":"73"},{"Code":"ETWF","Name":"White","ImageUrl":"media/31280192","VendorCode":"00"}]}],"VendorCode":"6","SKU":"B14285506"}]}},"Prices":[{"Quantity":{"From":1,"To":2147483647,"$index":1},"Price":18.480,"Cost":9.240,"DiscountCode":"P","CurrencyCode":"USD","IsQUR":false}],"PriceIncludes":"Blank product only"},{"Id":835649391,"Name":"2XL,Burnt Orange,Columbia Blue,Forest,Gold,Lime,Maroon,Navy,OD Green,Purple,Red,Royal,Sand,White,...","Description":"Size: 2XL","Attributes":{"Sizes":{"Values":[{"Code":"BBOB","Name":"2XL","Options":[{"Type":"Color","Values":[{"Code":"DLHF","Name":"Black","ImageUrl":"media/31280153","VendorCode":"50","$index":1},{"Code":"DROG","Name":"Burnt Orange","ImageUrl":"media/31280156","VendorCode":"66"},{"Code":"MEBL","Name":"Columbia Blue","ImageUrl":"media/31280159","VendorCode":"26"},{"Code":"DRGN","Name":"Forest","ImageUrl":"media/31280162","VendorCode":"54"},{"Code":"DRYE","Name":"Gold","ImageUrl":"media/31280165","VendorCode":"12"},{"Code":"FLGN","Name":"Lime","ImageUrl":"media/31280168","VendorCode":"16"},{"Code":"DRRD","Name":"Maroon","ImageUrl":"media/31280171","VendorCode":"53"},{"Code":"DRBL","Name":"Navy","ImageUrl":"media/31280174","VendorCode":"65"},{"Code":"FGRI","Name":"OD Green","ImageUrl":"media/31280177","VendorCode":"19"},{"Code":"MEPL","Name":"Purple","ImageUrl":"media/31280180","VendorCode":"67"},{"Code":"MERD","Name":"Red","ImageUrl":"media/31280183","VendorCode":"70"},{"Code":"FLBL","Name":"Royal","ImageUrl":"media/31280186","VendorCode":"75"},{"Code":"LIBR","Name":"Sand","ImageUrl":"media/31280189","VendorCode":"73"},{"Code":"ETWF","Name":"White","ImageUrl":"media/31280192","VendorCode":"00"}]}],"VendorCode":"7","SKU":"B14285507","$index":3}]}},"Prices":[{"Quantity":{"From":1,"To":2147483647,"$index":1},"Price":23.200,"Cost":11.600,"DiscountCode":"P","CurrencyCode":"USD","IsQUR":false}],"PriceIncludes":"Blank product only"},{"Id":835574717,"Name":"3XL,Burnt Orange,Columbia Blue,Forest,Gold,Lime,Maroon,Navy,OD Green,Purple,Red,Royal,Sand,White,...","Description":"Size: 3XL","Attributes":{"Sizes":{"Values":[{"Code":"BBOB","Name":"3XL","Options":[{"Type":"Color","Values":[{"Code":"DLHF","Name":"Black","ImageUrl":"media/31280153","VendorCode":"50","$index":1},{"Code":"DROG","Name":"Burnt Orange","ImageUrl":"media/31280156","VendorCode":"66"},{"Code":"MEBL","Name":"Columbia Blue","ImageUrl":"media/31280159","VendorCode":"26"},{"Code":"DRGN","Name":"Forest","ImageUrl":"media/31280162","VendorCode":"54"},{"Code":"DRYE","Name":"Gold","ImageUrl":"media/31280165","VendorCode":"12"},{"Code":"FLGN","Name":"Lime","ImageUrl":"media/31280168","VendorCode":"16"},{"Code":"DRRD","Name":"Maroon","ImageUrl":"media/31280171","VendorCode":"53"},{"Code":"DRBL","Name":"Navy","ImageUrl":"media/31280174","VendorCode":"65"},{"Code":"FGRI","Name":"OD Green","ImageUrl":"media/31280177","VendorCode":"19"},{"Code":"MEPL","Name":"Purple","ImageUrl":"media/31280180","VendorCode":"67"},{"Code":"MERD","Name":"Red","ImageUrl":"media/31280183","VendorCode":"70"},{"Code":"FLBL","Name":"Royal","ImageUrl":"media/31280186","VendorCode":"75"},{"Code":"LIBR","Name":"Sand","ImageUrl":"media/31280189","VendorCode":"73"},{"Code":"ETWF","Name":"White","ImageUrl":"media/31280192","VendorCode":"00"}]}],"VendorCode":"8","SKU":"B14285508","$index":3}]}},"Prices":[{"Quantity":{"From":1,"To":2147483647,"$index":1},"Price":28.500,"Cost":14.250,"DiscountCode":"P","CurrencyCode":"USD","IsQUR":false}],"PriceIncludes":"Blank product only"},{"Id":833827929,"Name":"4XL,Burnt Orange,Columbia Blue,Forest,Gold,Lime,Maroon,Navy,OD Green,Purple,Red,Royal,Sand,White,...","Description":"Size: 4XL","Attributes":{"Sizes":{"Values":[{"Code":"BBOB","Name":"4XL","Options":[{"Type":"Color","Values":[{"Code":"DLHF","Name":"Black","ImageUrl":"media/31280153","VendorCode":"50","$index":1},{"Code":"DROG","Name":"Burnt Orange","ImageUrl":"media/31280156","VendorCode":"66"},{"Code":"MEBL","Name":"Columbia Blue","ImageUrl":"media/31280159","VendorCode":"26"},{"Code":"DRGN","Name":"Forest","ImageUrl":"media/31280162","VendorCode":"54"},{"Code":"DRYE","Name":"Gold","ImageUrl":"media/31280165","VendorCode":"12"},{"Code":"FLGN","Name":"Lime","ImageUrl":"media/31280168","VendorCode":"16"},{"Code":"DRRD","Name":"Maroon","ImageUrl":"media/31280171","VendorCode":"53"},{"Code":"DRBL","Name":"Navy","ImageUrl":"media/31280174","VendorCode":"65"},{"Code":"FGRI","Name":"OD Green","ImageUrl":"media/31280177","VendorCode":"19"},{"Code":"MEPL","Name":"Purple","ImageUrl":"media/31280180","VendorCode":"67"},{"Code":"MERD","Name":"Red","ImageUrl":"media/31280183","VendorCode":"70"},{"Code":"FLBL","Name":"Royal","ImageUrl":"media/31280186","VendorCode":"75"},{"Code":"LIBR","Name":"Sand","ImageUrl":"media/31280189","VendorCode":"73"},{"Code":"ETWF","Name":"White","ImageUrl":"media/31280192","VendorCode":"00"}]}],"VendorCode":"9","SKU":"B14285509","$index":3}]}},"Prices":[{"Quantity":{"From":1,"To":2147483647,"$index":1},"Price":30.980,"Cost":15.490,"DiscountCode":"P","CurrencyCode":"USD","IsQUR":false}],"PriceIncludes":"Blank product only"}],"Warnings":[{"Name":"","Description":"No safety warnings for this product","Warning":"No safety warnings for this product","Type":"SWCH"}],"Prop65AdditionalInfo":"","Currency":"USD","Currencies":["USD"],"LowestPrice":{"Quantity":{"From":1,"To":2147483647,"$index":1},"Price":18.480,"Cost":9.240,"DiscountCode":"P","CurrencyCode":"USD","IsQUR":false},"HighestPrice":{"Quantity":{"From":1,"To":2147483647,"$index":1},"Price":30.980,"Cost":15.490,"DiscountCode":"P","CurrencyCode":"USD","IsQUR":false},"IsNew":false,"IsConfirmed":true,"HasFullColorProcess":false,"HasRushService":false,"UpdateDate":"2020-02-26T20:56:25.000-05:00","RequiresConfiguration":false,"Values":[{"Id":773581271,"Name":"Size","Description":"Size","Code":"SIZE","Values":[{"Id":761405622,"Name":"2XL","IsSelected":false,"VendorCode":"7"},{"Id":761405621,"Name":"3XL","IsSelected":false,"VendorCode":"8"},{"Id":782461296,"Name":"4XL","IsSelected":false,"VendorCode":"9"},{"Id":761405624,"Name":"L","IsSelected":false,"VendorCode":"5"},{"Id":761405625,"Name":"M","IsSelected":false,"VendorCode":"4"},{"Id":761405626,"Name":"S","IsSelected":false,"VendorCode":"3"},{"Id":761405623,"Name":"XL","IsSelected":false,"VendorCode":"6"},{"Id":782461297,"Name":"XS","IsSelected":false,"VendorCode":"2"}],"IsRequired":false,"IsMultiSelect":false},{"Id":773581272,"Name":"Material","Description":"Material","Code":"MTRL","Values":[{"Id":761405614,"Name":"Polyester","IsSelected":false}],"IsRequired":false,"IsMultiSelect":false},{"Id":24939750115,"Name":"Color","Description":"Product Color","Code":"PRCL","Values":[{"Id":24937885484,"Name":"Black","IsSelected":false,"VendorCode":"50"},{"Id":24939274257,"Name":"Black","IsSelected":false,"VendorCode":"50"},{"Id":24939274258,"Name":"Black","IsSelected":false,"VendorCode":"50"},{"Id":24939274259,"Name":"Black","IsSelected":false,"VendorCode":"50"},{"Id":24939274260,"Name":"Black","IsSelected":false,"VendorCode":"50"},{"Id":24939274261,"Name":"Black","IsSelected":false,"VendorCode":"50"},{"Id":24939274262,"Name":"Black","IsSelected":false,"VendorCode":"50"},{"Id":24939274263,"Name":"Black","IsSelected":false,"VendorCode":"50"},{"Id":24937885485,"Name":"Burnt Orange","IsSelected":false,"VendorCode":"66"},{"Id":24939274264,"Name":"Burnt Orange","IsSelected":false,"VendorCode":"66"},{"Id":24939274265,"Name":"Burnt Orange","IsSelected":false,"VendorCode":"66"},{"Id":24939274266,"Name":"Burnt Orange","IsSelected":false,"VendorCode":"66"},{"Id":24939274267,"Name":"Burnt Orange","IsSelected":false,"VendorCode":"66"},{"Id":24939274268,"Name":"Burnt Orange","IsSelected":false,"VendorCode":"66"},{"Id":24939274269,"Name":"Burnt Orange","IsSelected":false,"VendorCode":"66"},{"Id":24939274270,"Name":"Burnt Orange","IsSelected":false,"VendorCode":"66"},{"Id":24937885486,"Name":"Columbia Blue","IsSelected":false,"VendorCode":"26"},{"Id":24939274271,"Name":"Columbia Blue","IsSelected":false,"VendorCode":"26"},{"Id":24939274272,"Name":"Columbia Blue","IsSelected":false,"VendorCode":"26"},{"Id":24939274273,"Name":"Columbia Blue","IsSelected":false,"VendorCode":"26"},{"Id":24939274274,"Name":"Columbia Blue","IsSelected":false,"VendorCode":"26"},{"Id":24939274275,"Name":"Columbia Blue","IsSelected":false,"VendorCode":"26"},{"Id":24939274276,"Name":"Columbia Blue","IsSelected":false,"VendorCode":"26"},{"Id":24939274277,"Name":"Columbia Blue","IsSelected":false,"VendorCode":"26"},{"Id":24937868054,"Name":"Forest","IsSelected":false,"VendorCode":"54"},{"Id":24939308974,"Name":"Forest","IsSelected":false,"VendorCode":"54"},{"Id":24939308975,"Name":"Forest","IsSelected":false,"VendorCode":"54"},{"Id":24939308976,"Name":"Forest","IsSelected":false,"VendorCode":"54"},{"Id":24939308977,"Name":"Forest","IsSelected":false,"VendorCode":"54"},{"Id":24939308978,"Name":"Forest","IsSelected":false,"VendorCode":"54"},{"Id":24939308979,"Name":"Forest","IsSelected":false,"VendorCode":"54"},{"Id":24939308980,"Name":"Forest","IsSelected":false,"VendorCode":"54"},{"Id":24937885487,"Name":"Gold","IsSelected":false,"VendorCode":"12"},{"Id":24939274278,"Name":"Gold","IsSelected":false,"VendorCode":"12"},{"Id":24939274279,"Name":"Gold","IsSelected":false,"VendorCode":"12"},{"Id":24939274280,"Name":"Gold","IsSelected":false,"VendorCode":"12"},{"Id":24939274281,"Name":"Gold","IsSelected":false,"VendorCode":"12"},{"Id":24939274282,"Name":"Gold","IsSelected":false,"VendorCode":"12"},{"Id":24939274283,"Name":"Gold","IsSelected":false,"VendorCode":"12"},{"Id":24939274284,"Name":"Gold","IsSelected":false,"VendorCode":"12"},{"Id":24937868055,"Name":"Lime","IsSelected":false,"VendorCode":"16"},{"Id":24939308981,"Name":"Lime","IsSelected":false,"VendorCode":"16"},{"Id":24939308982,"Name":"Lime","IsSelected":false,"VendorCode":"16"},{"Id":24939308983,"Name":"Lime","IsSelected":false,"VendorCode":"16"},{"Id":24939308984,"Name":"Lime","IsSelected":false,"VendorCode":"16"},{"Id":24939308985,"Name":"Lime","IsSelected":false,"VendorCode":"16"},{"Id":24939308986,"Name":"Lime","IsSelected":false,"VendorCode":"16"},{"Id":24939308987,"Name":"Lime","IsSelected":false,"VendorCode":"16"},{"Id":24937885810,"Name":"Maroon","IsSelected":false,"VendorCode":"53"},{"Id":24939274285,"Name":"Maroon","IsSelected":false,"VendorCode":"53"},{"Id":24939274286,"Name":"Maroon","IsSelected":false,"VendorCode":"53"},{"Id":24939274287,"Name":"Maroon","IsSelected":false,"VendorCode":"53"},{"Id":24939274288,"Name":"Maroon","IsSelected":false,"VendorCode":"53"},{"Id":24939274289,"Name":"Maroon","IsSelected":false,"VendorCode":"53"},{"Id":24939274290,"Name":"Maroon","IsSelected":false,"VendorCode":"53"},{"Id":24939274291,"Name":"Maroon","IsSelected":false,"VendorCode":"53"},{"Id":24937869176,"Name":"Navy","IsSelected":false,"VendorCode":"65"},{"Id":24939308988,"Name":"Navy","IsSelected":false,"VendorCode":"65"},{"Id":24939308989,"Name":"Navy","IsSelected":false,"VendorCode":"65"},{"Id":24939308990,"Name":"Navy","IsSelected":false,"VendorCode":"65"},{"Id":24939308991,"Name":"Navy","IsSelected":false,"VendorCode":"65"},{"Id":24939308992,"Name":"Navy","IsSelected":false,"VendorCode":"65"},{"Id":24939308993,"Name":"Navy","IsSelected":false,"VendorCode":"65"},{"Id":24939308994,"Name":"Navy","IsSelected":false,"VendorCode":"65"},{"Id":24937884848,"Name":"OD Green","IsSelected":false,"VendorCode":"19"},{"Id":24939274292,"Name":"OD Green","IsSelected":false,"VendorCode":"19"},{"Id":24939274293,"Name":"OD Green","IsSelected":false,"VendorCode":"19"},{"Id":24939274294,"Name":"OD Green","IsSelected":false,"VendorCode":"19"},{"Id":24939274295,"Name":"OD Green","IsSelected":false,"VendorCode":"19"},{"Id":24939274296,"Name":"OD Green","IsSelected":false,"VendorCode":"19"},{"Id":24939274297,"Name":"OD Green","IsSelected":false,"VendorCode":"19"},{"Id":24939274298,"Name":"OD Green","IsSelected":false,"VendorCode":"19"},{"Id":24937885811,"Name":"Purple","IsSelected":false,"VendorCode":"67"},{"Id":24939274299,"Name":"Purple","IsSelected":false,"VendorCode":"67"},{"Id":24939274300,"Name":"Purple","IsSelected":false,"VendorCode":"67"},{"Id":24939274301,"Name":"Purple","IsSelected":false,"VendorCode":"67"},{"Id":24939274302,"Name":"Purple","IsSelected":false,"VendorCode":"67"},{"Id":24939274303,"Name":"Purple","IsSelected":false,"VendorCode":"67"},{"Id":24939274304,"Name":"Purple","IsSelected":false,"VendorCode":"67"},{"Id":24939274305,"Name":"Purple","IsSelected":false,"VendorCode":"67"},{"Id":24937869392,"Name":"Red","IsSelected":false,"VendorCode":"70"},{"Id":24939308995,"Name":"Red","IsSelected":false,"VendorCode":"70"},{"Id":24939308996,"Name":"Red","IsSelected":false,"VendorCode":"70"},{"Id":24939308997,"Name":"Red","IsSelected":false,"VendorCode":"70"},{"Id":24939308998,"Name":"Red","IsSelected":false,"VendorCode":"70"},{"Id":24939308999,"Name":"Red","IsSelected":false,"VendorCode":"70"},{"Id":24939309000,"Name":"Red","IsSelected":false,"VendorCode":"70"},{"Id":24939309001,"Name":"Red","IsSelected":false,"VendorCode":"70"},{"Id":24937869177,"Name":"Royal","IsSelected":false,"VendorCode":"75"},{"Id":24939309002,"Name":"Royal","IsSelected":false,"VendorCode":"75"},{"Id":24939309003,"Name":"Royal","IsSelected":false,"VendorCode":"75"},{"Id":24939309004,"Name":"Royal","IsSelected":false,"VendorCode":"75"},{"Id":24939309005,"Name":"Royal","IsSelected":false,"VendorCode":"75"},{"Id":24939309006,"Name":"Royal","IsSelected":false,"VendorCode":"75"},{"Id":24939309007,"Name":"Royal","IsSelected":false,"VendorCode":"75"},{"Id":24939309008,"Name":"Royal","IsSelected":false,"VendorCode":"75"},{"Id":24937867259,"Name":"Sand","IsSelected":false,"VendorCode":"73"},{"Id":24939309009,"Name":"Sand","IsSelected":false,"VendorCode":"73"},{"Id":24939309010,"Name":"Sand","IsSelected":false,"VendorCode":"73"},{"Id":24939309011,"Name":"Sand","IsSelected":false,"VendorCode":"73"},{"Id":24939309012,"Name":"Sand","IsSelected":false,"VendorCode":"73"},{"Id":24939309013,"Name":"Sand","IsSelected":false,"VendorCode":"73"},{"Id":24939309014,"Name":"Sand","IsSelected":false,"VendorCode":"73"},{"Id":24939309015,"Name":"Sand","IsSelected":false,"VendorCode":"73"},{"Id":24937867260,"Name":"White","IsSelected":false,"VendorCode":"00"},{"Id":24939309016,"Name":"White","IsSelected":false,"VendorCode":"00"},{"Id":24939309017,"Name":"White","IsSelected":false,"VendorCode":"00"},{"Id":24939309018,"Name":"White","IsSelected":false,"VendorCode":"00"},{"Id":24939309019,"Name":"White","IsSelected":false,"VendorCode":"00"},{"Id":24939309020,"Name":"White","IsSelected":false,"VendorCode":"00"},{"Id":24939309021,"Name":"White","IsSelected":false,"VendorCode":"00"},{"Id":24939309022,"Name":"White","IsSelected":false,"VendorCode":"00"}],"IsRequired":false,"IsMultiSelect":false}],"SKU":[{"SKU":"B14285502","Values":[{"Code":"SIZE","Name":"XS","VendorCode":"2"},{"Code":"PRCL","Name":"Black","VendorCode":"50"}]},{"SKU":"B14285503","Values":[{"Code":"SIZE","Name":"S","VendorCode":"3"},{"Code":"PRCL","Name":"Black","VendorCode":"50"}]},{"SKU":"B14285504","Values":[{"Code":"SIZE","Name":"M","VendorCode":"4"},{"Code":"PRCL","Name":"Black","VendorCode":"50"}]},{"SKU":"B14285505","Values":[{"Code":"SIZE","Name":"L","VendorCode":"5"},{"Code":"PRCL","Name":"Black","VendorCode":"50"}]},{"SKU":"B14285506","Values":[{"Code":"SIZE","Name":"XL","VendorCode":"6"},{"Code":"PRCL","Name":"Black","VendorCode":"50"}]},{"SKU":"B14285507","Values":[{"Code":"SIZE","Name":"2XL","VendorCode":"7"},{"Code":"PRCL","Name":"Black","VendorCode":"50"}]},{"SKU":"B14285508","Values":[{"Code":"SIZE","Name":"3XL","VendorCode":"8"},{"Code":"PRCL","Name":"Black","VendorCode":"50"}]},{"SKU":"B14285509","Values":[{"Code":"SIZE","Name":"4XL","VendorCode":"9"},{"Code":"PRCL","Name":"Black","VendorCode":"50"}]},{"SKU":"B14285662","Values":[{"Code":"SIZE","Name":"XS","VendorCode":"2"},{"Code":"PRCL","Name":"Burnt Orange","VendorCode":"66"}]},{"SKU":"B14285663","Values":[{"Code":"SIZE","Name":"S","VendorCode":"3"},{"Code":"PRCL","Name":"Burnt Orange","VendorCode":"66"}]},{"SKU":"B14285664","Values":[{"Code":"SIZE","Name":"M","VendorCode":"4"},{"Code":"PRCL","Name":"Burnt Orange","VendorCode":"66"}]},{"SKU":"B14285665","Values":[{"Code":"SIZE","Name":"L","VendorCode":"5"},{"Code":"PRCL","Name":"Burnt Orange","VendorCode":"66"}]},{"SKU":"B14285666","Values":[{"Code":"SIZE","Name":"XL","VendorCode":"6"},{"Code":"PRCL","Name":"Burnt Orange","VendorCode":"66"}]},{"SKU":"B14285667","Values":[{"Code":"SIZE","Name":"2XL","VendorCode":"7"},{"Code":"PRCL","Name":"Burnt Orange","VendorCode":"66"}]},{"SKU":"B14285668","Values":[{"Code":"SIZE","Name":"3XL","VendorCode":"8"},{"Code":"PRCL","Name":"Burnt Orange","VendorCode":"66"}]},{"SKU":"B14285669","Values":[{"Code":"SIZE","Name":"4XL","VendorCode":"9"},{"Code":"PRCL","Name":"Burnt Orange","VendorCode":"66"}]},{"SKU":"B14285262","Values":[{"Code":"SIZE","Name":"XS","VendorCode":"2"},{"Code":"PRCL","Name":"Columbia Blue","VendorCode":"26"}]},{"SKU":"B14285263","Values":[{"Code":"SIZE","Name":"S","VendorCode":"3"},{"Code":"PRCL","Name":"Columbia Blue","VendorCode":"26"}]},{"SKU":"B14285264","Values":[{"Code":"SIZE","Name":"M","VendorCode":"4"},{"Code":"PRCL","Name":"Columbia Blue","VendorCode":"26"}]},{"SKU":"B14285265","Values":[{"Code":"SIZE","Name":"L","VendorCode":"5"},{"Code":"PRCL","Name":"Columbia Blue","VendorCode":"26"}]},{"SKU":"B14285266","Values":[{"Code":"SIZE","Name":"XL","VendorCode":"6"},{"Code":"PRCL","Name":"Columbia Blue","VendorCode":"26"}]},{"SKU":"B14285267","Values":[{"Code":"SIZE","Name":"2XL","VendorCode":"7"},{"Code":"PRCL","Name":"Columbia Blue","VendorCode":"26"}]},{"SKU":"B14285268","Values":[{"Code":"SIZE","Name":"3XL","VendorCode":"8"},{"Code":"PRCL","Name":"Columbia Blue","VendorCode":"26"}]},{"SKU":"B14285269","Values":[{"Code":"SIZE","Name":"4XL","VendorCode":"9"},{"Code":"PRCL","Name":"Columbia Blue","VendorCode":"26"}]},{"SKU":"B14285542","Values":[{"Code":"SIZE","Name":"XS","VendorCode":"2"},{"Code":"PRCL","Name":"Forest","VendorCode":"54"}]},{"SKU":"B14285543","Values":[{"Code":"SIZE","Name":"S","VendorCode":"3"},{"Code":"PRCL","Name":"Forest","VendorCode":"54"}]},{"SKU":"B14285544","Values":[{"Code":"SIZE","Name":"M","VendorCode":"4"},{"Code":"PRCL","Name":"Forest","VendorCode":"54"}]},{"SKU":"B14285545","Values":[{"Code":"SIZE","Name":"L","VendorCode":"5"},{"Code":"PRCL","Name":"Forest","VendorCode":"54"}]},{"SKU":"B14285546","Values":[{"Code":"SIZE","Name":"XL","VendorCode":"6"},{"Code":"PRCL","Name":"Forest","VendorCode":"54"}]},{"SKU":"B14285547","Values":[{"Code":"SIZE","Name":"2XL","VendorCode":"7"},{"Code":"PRCL","Name":"Forest","VendorCode":"54"}]},{"SKU":"B14285548","Values":[{"Code":"SIZE","Name":"3XL","VendorCode":"8"},{"Code":"PRCL","Name":"Forest","VendorCode":"54"}]},{"SKU":"B14285549","Values":[{"Code":"SIZE","Name":"4XL","VendorCode":"9"},{"Code":"PRCL","Name":"Forest","VendorCode":"54"}]},{"SKU":"B14285122","Values":[{"Code":"SIZE","Name":"XS","VendorCode":"2"},{"Code":"PRCL","Name":"Gold","VendorCode":"12"}]},{"SKU":"B14285123","Values":[{"Code":"SIZE","Name":"S","VendorCode":"3"},{"Code":"PRCL","Name":"Gold","VendorCode":"12"}]},{"SKU":"B14285124","Values":[{"Code":"SIZE","Name":"M","VendorCode":"4"},{"Code":"PRCL","Name":"Gold","VendorCode":"12"}]},{"SKU":"B14285125","Values":[{"Code":"SIZE","Name":"L","VendorCode":"5"},{"Code":"PRCL","Name":"Gold","VendorCode":"12"}]},{"SKU":"B14285126","Values":[{"Code":"SIZE","Name":"XL","VendorCode":"6"},{"Code":"PRCL","Name":"Gold","VendorCode":"12"}]},{"SKU":"B14285127","Values":[{"Code":"SIZE","Name":"2XL","VendorCode":"7"},{"Code":"PRCL","Name":"Gold","VendorCode":"12"}]},{"SKU":"B14285128","Values":[{"Code":"SIZE","Name":"3XL","VendorCode":"8"},{"Code":"PRCL","Name":"Gold","VendorCode":"12"}]},{"SKU":"B14285129","Values":[{"Code":"SIZE","Name":"4XL","VendorCode":"9"},{"Code":"PRCL","Name":"Gold","VendorCode":"12"}]},{"SKU":"B14285162","Values":[{"Code":"SIZE","Name":"XS","VendorCode":"2"},{"Code":"PRCL","Name":"Lime","VendorCode":"16"}]},{"SKU":"B14285163","Values":[{"Code":"SIZE","Name":"S","VendorCode":"3"},{"Code":"PRCL","Name":"Lime","VendorCode":"16"}]},{"SKU":"B14285164","Values":[{"Code":"SIZE","Name":"M","VendorCode":"4"},{"Code":"PRCL","Name":"Lime","VendorCode":"16"}]},{"SKU":"B14285165","Values":[{"Code":"SIZE","Name":"L","VendorCode":"5"},{"Code":"PRCL","Name":"Lime","VendorCode":"16"}]},{"SKU":"B14285166","Values":[{"Code":"SIZE","Name":"XL","VendorCode":"6"},{"Code":"PRCL","Name":"Lime","VendorCode":"16"}]},{"SKU":"B14285167","Values":[{"Code":"SIZE","Name":"2XL","VendorCode":"7"},{"Code":"PRCL","Name":"Lime","VendorCode":"16"}]},{"SKU":"B14285168","Values":[{"Code":"SIZE","Name":"3XL","VendorCode":"8"},{"Code":"PRCL","Name":"Lime","VendorCode":"16"}]},{"SKU":"B14285169","Values":[{"Code":"SIZE","Name":"4XL","VendorCode":"9"},{"Code":"PRCL","Name":"Lime","VendorCode":"16"}]},{"SKU":"B14285532","Values":[{"Code":"SIZE","Name":"XS","VendorCode":"2"},{"Code":"PRCL","Name":"Maroon","VendorCode":"53"}]},{"SKU":"B14285533","Values":[{"Code":"SIZE","Name":"S","VendorCode":"3"},{"Code":"PRCL","Name":"Maroon","VendorCode":"53"}]},{"SKU":"B14285534","Values":[{"Code":"SIZE","Name":"M","VendorCode":"4"},{"Code":"PRCL","Name":"Maroon","VendorCode":"53"}]},{"SKU":"B14285535","Values":[{"Code":"SIZE","Name":"L","VendorCode":"5"},{"Code":"PRCL","Name":"Maroon","VendorCode":"53"}]},{"SKU":"B14285536","Values":[{"Code":"SIZE","Name":"XL","VendorCode":"6"},{"Code":"PRCL","Name":"Maroon","VendorCode":"53"}]},{"SKU":"B14285537","Values":[{"Code":"SIZE","Name":"2XL","VendorCode":"7"},{"Code":"PRCL","Name":"Maroon","VendorCode":"53"}]},{"SKU":"B14285538","Values":[{"Code":"SIZE","Name":"3XL","VendorCode":"8"},{"Code":"PRCL","Name":"Maroon","VendorCode":"53"}]},{"SKU":"B14285539","Values":[{"Code":"SIZE","Name":"4XL","VendorCode":"9"},{"Code":"PRCL","Name":"Maroon","VendorCode":"53"}]},{"SKU":"B14285652","Values":[{"Code":"SIZE","Name":"XS","VendorCode":"2"},{"Code":"PRCL","Name":"Navy","VendorCode":"65"}]},{"SKU":"B14285653","Values":[{"Code":"SIZE","Name":"S","VendorCode":"3"},{"Code":"PRCL","Name":"Navy","VendorCode":"65"}]},{"SKU":"B14285654","Values":[{"Code":"SIZE","Name":"M","VendorCode":"4"},{"Code":"PRCL","Name":"Navy","VendorCode":"65"}]},{"SKU":"B14285656","Values":[{"Code":"SIZE","Name":"XL","VendorCode":"6"},{"Code":"PRCL","Name":"Navy","VendorCode":"65"}]},{"SKU":"B14285657","Values":[{"Code":"SIZE","Name":"2XL","VendorCode":"7"},{"Code":"PRCL","Name":"Navy","VendorCode":"65"}]},{"SKU":"B14285658","Values":[{"Code":"SIZE","Name":"3XL","VendorCode":"8"},{"Code":"PRCL","Name":"Navy","VendorCode":"65"}]},{"SKU":"B14285659","Values":[{"Code":"SIZE","Name":"4XL","VendorCode":"9"},{"Code":"PRCL","Name":"Navy","VendorCode":"65"}]},{"SKU":"B14285192","Values":[{"Code":"SIZE","Name":"XS","VendorCode":"2"},{"Code":"PRCL","Name":"OD Green","VendorCode":"19"}]},{"SKU":"B14285193","Values":[{"Code":"SIZE","Name":"S","VendorCode":"3"},{"Code":"PRCL","Name":"OD Green","VendorCode":"19"}]},{"SKU":"B14285194","Values":[{"Code":"SIZE","Name":"M","VendorCode":"4"},{"Code":"PRCL","Name":"OD Green","VendorCode":"19"}]},{"SKU":"B14285195","Values":[{"Code":"SIZE","Name":"L","VendorCode":"5"},{"Code":"PRCL","Name":"OD Green","VendorCode":"19"}]},{"SKU":"B14285196","Values":[{"Code":"SIZE","Name":"XL","VendorCode":"6"},{"Code":"PRCL","Name":"OD Green","VendorCode":"19"}]},{"SKU":"B14285197","Values":[{"Code":"SIZE","Name":"2XL","VendorCode":"7"},{"Code":"PRCL","Name":"OD Green","VendorCode":"19"}]},{"SKU":"B14285198","Values":[{"Code":"SIZE","Name":"3XL","VendorCode":"8"},{"Code":"PRCL","Name":"OD Green","VendorCode":"19"}]},{"SKU":"B14285199","Values":[{"Code":"SIZE","Name":"4XL","VendorCode":"9"},{"Code":"PRCL","Name":"OD Green","VendorCode":"19"}]},{"SKU":"B14285672","Values":[{"Code":"SIZE","Name":"XS","VendorCode":"2"},{"Code":"PRCL","Name":"Purple","VendorCode":"67"}]},{"SKU":"B14285673","Values":[{"Code":"SIZE","Name":"S","VendorCode":"3"},{"Code":"PRCL","Name":"Purple","VendorCode":"67"}]},{"SKU":"B14285674","Values":[{"Code":"SIZE","Name":"M","VendorCode":"4"},{"Code":"PRCL","Name":"Purple","VendorCode":"67"}]},{"SKU":"B14285675","Values":[{"Code":"SIZE","Name":"L","VendorCode":"5"},{"Code":"PRCL","Name":"Purple","VendorCode":"67"}]},{"SKU":"B14285676","Values":[{"Code":"SIZE","Name":"XL","VendorCode":"6"},{"Code":"PRCL","Name":"Purple","VendorCode":"67"}]},{"SKU":"B14285677","Values":[{"Code":"SIZE","Name":"2XL","VendorCode":"7"},{"Code":"PRCL","Name":"Purple","VendorCode":"67"}]},{"SKU":"B14285678","Values":[{"Code":"SIZE","Name":"3XL","VendorCode":"8"},{"Code":"PRCL","Name":"Purple","VendorCode":"67"}]},{"SKU":"B14285679","Values":[{"Code":"SIZE","Name":"4XL","VendorCode":"9"},{"Code":"PRCL","Name":"Purple","VendorCode":"67"}]},{"SKU":"B14285702","Values":[{"Code":"SIZE","Name":"XS","VendorCode":"2"},{"Code":"PRCL","Name":"Red","VendorCode":"70"}]},{"SKU":"B14285703","Values":[{"Code":"SIZE","Name":"S","VendorCode":"3"},{"Code":"PRCL","Name":"Red","VendorCode":"70"}]},{"SKU":"B14285704","Values":[{"Code":"SIZE","Name":"M","VendorCode":"4"},{"Code":"PRCL","Name":"Red","VendorCode":"70"}]},{"SKU":"B14285706","Values":[{"Code":"SIZE","Name":"XL","VendorCode":"6"},{"Code":"PRCL","Name":"Red","VendorCode":"70"}]},{"SKU":"B14285707","Values":[{"Code":"SIZE","Name":"2XL","VendorCode":"7"},{"Code":"PRCL","Name":"Red","VendorCode":"70"}]},{"SKU":"B14285708","Values":[{"Code":"SIZE","Name":"3XL","VendorCode":"8"},{"Code":"PRCL","Name":"Red","VendorCode":"70"}]},{"SKU":"B14285709","Values":[{"Code":"SIZE","Name":"4XL","VendorCode":"9"},{"Code":"PRCL","Name":"Red","VendorCode":"70"}]},{"SKU":"B14285752","Values":[{"Code":"SIZE","Name":"XS","VendorCode":"2"},{"Code":"PRCL","Name":"Royal","VendorCode":"75"}]},{"SKU":"B14285755","Values":[{"Code":"SIZE","Name":"L","VendorCode":"5"},{"Code":"PRCL","Name":"Royal","VendorCode":"75"}]},{"SKU":"B14285759","Values":[{"Code":"SIZE","Name":"4XL","VendorCode":"9"},{"Code":"PRCL","Name":"Royal","VendorCode":"75"}]},{"SKU":"B14285732","Values":[{"Code":"SIZE","Name":"XS","VendorCode":"2"},{"Code":"PRCL","Name":"Sand","VendorCode":"73"}]},{"SKU":"B14285733","Values":[{"Code":"SIZE","Name":"S","VendorCode":"3"},{"Code":"PRCL","Name":"Sand","VendorCode":"73"}]},{"SKU":"B14285734","Values":[{"Code":"SIZE","Name":"M","VendorCode":"4"},{"Code":"PRCL","Name":"Sand","VendorCode":"73"}]},{"SKU":"B14285735","Values":[{"Code":"SIZE","Name":"L","VendorCode":"5"},{"Code":"PRCL","Name":"Sand","VendorCode":"73"}]},{"SKU":"B14285736","Values":[{"Code":"SIZE","Name":"XL","VendorCode":"6"},{"Code":"PRCL","Name":"Sand","VendorCode":"73"}]},{"SKU":"B14285737","Values":[{"Code":"SIZE","Name":"2XL","VendorCode":"7"},{"Code":"PRCL","Name":"Sand","VendorCode":"73"}]},{"SKU":"B14285738","Values":[{"Code":"SIZE","Name":"3XL","VendorCode":"8"},{"Code":"PRCL","Name":"Sand","VendorCode":"73"}]},{"SKU":"B14285739","Values":[{"Code":"SIZE","Name":"4XL","VendorCode":"9"},{"Code":"PRCL","Name":"Sand","VendorCode":"73"}]},{"SKU":"B14285002","Values":[{"Code":"SIZE","Name":"XS","VendorCode":"2"},{"Code":"PRCL","Name":"White","VendorCode":"00"}]},{"SKU":"B14285003","Values":[{"Code":"SIZE","Name":"S","VendorCode":"3"},{"Code":"PRCL","Name":"White","VendorCode":"00"}]},{"SKU":"B14285004","Values":[{"Code":"SIZE","Name":"M","VendorCode":"4"},{"Code":"PRCL","Name":"White","VendorCode":"00"}]},{"SKU":"B14285006","Values":[{"Code":"SIZE","Name":"XL","VendorCode":"6"},{"Code":"PRCL","Name":"White","VendorCode":"00"}]},{"SKU":"B14285007","Values":[{"Code":"SIZE","Name":"2XL","VendorCode":"7"},{"Code":"PRCL","Name":"White","VendorCode":"00"}]},{"SKU":"B14285008","Values":[{"Code":"SIZE","Name":"3XL","VendorCode":"8"},{"Code":"PRCL","Name":"White","VendorCode":"00"}]},{"SKU":"B14285009","Values":[{"Code":"SIZE","Name":"4XL","VendorCode":"9"},{"Code":"PRCL","Name":"White","VendorCode":"00"}]},{"SKU":"B14285753","Values":[{"Code":"SIZE","Name":"S","VendorCode":"3"},{"Code":"PRCL","Name":"Royal","VendorCode":"75"}]},{"SKU":"B14285758","Values":[{"Code":"SIZE","Name":"3XL","VendorCode":"8"},{"Code":"PRCL","Name":"Royal","VendorCode":"75"}]},{"SKU":"B14285754","Values":[{"Code":"SIZE","Name":"M","VendorCode":"4"},{"Code":"PRCL","Name":"Royal","VendorCode":"75"}]},{"SKU":"B14285756","Values":[{"Code":"SIZE","Name":"XL","VendorCode":"6"},{"Code":"PRCL","Name":"Royal","VendorCode":"75"}]},{"SKU":"B14285757","Values":[{"Code":"SIZE","Name":"2XL","VendorCode":"7"},{"Code":"PRCL","Name":"Royal","VendorCode":"75"}]},{"SKU":"B14285705","Values":[{"Code":"SIZE","Name":"L","VendorCode":"5"},{"Code":"PRCL","Name":"Red","VendorCode":"70"}]},{"SKU":"B14285005","Values":[{"Code":"SIZE","Name":"L","VendorCode":"5"},{"Code":"PRCL","Name":"White","VendorCode":"00"}]},{"SKU":"B14285655","Values":[{"Code":"SIZE","Name":"L","VendorCode":"5"},{"Code":"PRCL","Name":"Navy","VendorCode":"65"}]}],"IsAssembled":true,"HasInventory":true,"Services":[{"Id":550005773,"Name":"Inventory API","Code":"IAPI"},{"Id":550005239,"Name":"Order Creation API","Code":"OAPI"},{"Id":550005774,"Name":"Product API","Code":"PAPI"},{"Id":550005235,"Name":"Pricing API","Code":"RAPI"},{"Id":550005248,"Name":"Order Status API","Code":"SAPI"}]}';
    ESPProduct espProductObj = new ESPProduct();
    espProductObj.parse(jsonData, '');
    espProductObj.getSpecificProductSizeDetails('3840073');
    espProductObj.getSpecificProductColorDetails('3840073');
    espProductObj.getImagesOfSpecificProduct('3840073');
    espProductObj.getAttributesOfSpecificProduct('3840073');
    espProductObj.getPricesOfSpecificProduct('3840073');
    espProductObj.getCustomDescription('3840073');
    espProductObj.getsku('3840073');
  }

  static testMethod void testParseShipping() {
    String shippingObjJson = '{\"TestAMissingObject\": { \"TestAMissingArray\": [ { \"TestAMissingProperty\": \"Some Value\" } ] } }';
    Map<String, Object> mapShipping = (Map<String, Object>) JSON.deserializeUntyped(
      shippingObjJson
    );
    ESPProduct.Shipping objShipping = new ESPProduct.Shipping(mapShipping);
  }
}
