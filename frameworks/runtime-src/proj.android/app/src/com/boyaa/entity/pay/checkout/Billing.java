/* Copyright (c) 2013 Pozirk Games
 * http://www.pozirk.com
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package com.boyaa.entity.pay.checkout;

import android.app.Activity;
import android.content.Intent;
import android.util.Log;

import com.boyaa.entity.pay.checkout.v3.IabHelper;
import com.boyaa.entity.pay.checkout.v3.IabResult;
import com.boyaa.entity.pay.checkout.v3.Inventory;
import com.boyaa.entity.pay.checkout.v3.Purchase;
import com.boyaa.entity.pay.checkout.v3.SkuDetails;

import java.util.List;

public class Billing {
	static final int RC_REQUEST = 20003; //[update: what this for?]
	
	protected static Billing _instance = null;
	
	IabHelper _helper;
	String _sku, _type, _payload;
	Activity _act;
	Inventory _inventory;
	
	public void schedulePurchase(String sku, String type, String payload) {
		_sku = sku;
		_type = type;
		_payload = payload;
	}
	
	public void purchase(Activity act) {
		if (_helper == null)
			return;
		if (!_helper.isAsyncInProgress()) //to prevent starting another async operation
		{
			_act = act;
			_helper.launchPurchaseFlow(act, _sku, _type, RC_REQUEST, _onPurchase, _payload);
		}
	}
	
	public Activity activity() {
		return _act;
	}
	
	public void endPurchase(Activity act) {
		if (act == _act) //I guess :), that Activities are created and destroyed asynchronously, so don't let to null wrong Activity
		{
			_act = null;
			_helper.flagEndAsync();
		}
	}
	
	public boolean handlePurchaseResult(int requestCode, int resultCode, Intent data) {
		boolean b = true;
		if (_helper != null)
			b = _helper.handleActivityResult(requestCode, resultCode, data);
		return b;
	}
	
	IabHelper.OnIabPurchaseFinishedListener _onPurchase = new IabHelper.OnIabPurchaseFinishedListener() {
		public void onIabPurchaseFinished(IabResult result, Purchase purchase) {
			String sku = "";
			String orderID = "";
			if (purchase != null) {
				sku = purchase.getSku();
				orderID = purchase.getDeveloperPayload();
			}
//			Log.d("test", "gwjgwj,purchase finished:"+result.isFailure()+", sku="+sku+","+_sku);
			if (result.isFailure()) {
//				Log.d("test", "gwjgwj,response:" + result.getResponse());
				if (result.getResponse() == IabHelper.BILLING_RESPONSE_RESULT_ITEM_ALREADY_OWNED) {
//					CallLuaUtil.call(HandMachine.kPlayStorePurchase, HandMachine.kCallSuccess, new String[]{"flag"}, new Object[]{_sku});

				}
				/*else if(result.getResponse() == IabHelper.BILLING_RESPONSE_RESULT_USER_CANCELED)
					_ctx.dispatchStatusEventAsync("PURCHASE_USER_CANCELLED", _sku);*/
				else {
//					CallLuaUtil.call(HandMachine.kPlayStorePurchase, HandMachine.kCallFailed, new String[]{"flag"}, new Object[]{result.getMessage()});
				}
				
			} else if (sku.equals(_sku)) { //[update: not good, need to fix that]
//				CallLuaUtil.call(HandMachine.kPlayStorePurchase, HandMachine.kCallSuccess, new String[]{"flag", "orderID"}, new Object[]{sku, orderID});
			} else {
//				CallLuaUtil.call(HandMachine.kPlayStorePurchase, HandMachine.kCallFailed, new String[]{"flag"}, new Object[]{sku});
			}
			
			if (Billing.getInstance()._act != null)
				Billing.getInstance()._act.finish();
			_act = null;
		}
	};
	
	//now query both regular items and subscriptions
	public void restore(List<String> items, List<String> subs) {
		_helper.queryInventoryAsync(true, items, subs, _onRestore);
	}
	
	IabHelper.QueryInventoryFinishedListener _onRestore = new IabHelper.QueryInventoryFinishedListener() {
		public void onQueryInventoryFinished(IabResult result, Inventory inventory) {
			Log.d("test", "gwjgwj,onQueryInventoryFinished:" + result.isFailure() + "," + result.getResponse() + "," + result.getMessage());
			if (result.isFailure()) {
//				CallLuaUtil.call(HandMachine.kRestore, HandMachine.kCallFailed, new String[]{"flag"}, new Object[]{result.getMessage()});
			} else {
				Billing.getInstance()._inventory = inventory;
				
//				CallLuaUtil.call(HandMachine.kRestore, HandMachine.kCallSuccess, new String[]{"flag"}, new Object[]{"ku-ku"});
			}
		}
	};
	
	public void consume(String sku) {
//		Log.d("test", "gwjgwj,Billing.consume,sku=" + sku);
		if (_inventory != null) {
			Purchase purchase = _inventory.getPurchase(sku);
			if (purchase != null)
				_helper.consumeAsync(purchase, _onConsumeFinished);
			else {
//				CallLuaUtil.call(HandMachine.kPlayStoreConsume, HandMachine.kCallFailed, new String[]{"flag"}, new Object[]{"Purchase not found."});
				
			}
			
		} else {
//			CallLuaUtil.call(HandMachine.kPlayStoreConsume, HandMachine.kCallFailed, new String[]{"flag"}, new Object[]{"Can't consume a product, restore transactions first."});
			
		}
		
	}
	
	IabHelper.OnConsumeFinishedListener _onConsumeFinished = new IabHelper.OnConsumeFinishedListener() {
		public void onConsumeFinished(Purchase purchase, IabResult result) {
//			Log.d("test", "gwjgwj,consume finished:" + result.isSuccess());
			if (result.isSuccess()) {
//				CallLuaUtil.call(HandMachine.kPlayStoreConsume, HandMachine.kCallSuccess, new String[]{"flag"}, new Object[]{purchase.getSku()});
				
			} else {
//				CallLuaUtil.call(HandMachine.kPlayStoreConsume, HandMachine.kCallFailed, new String[]{"flag"}, new Object[]{result.getMessage()});
				
			}
			
		}
	};
	
	public Purchase getPurchaseDetails(String sku) {
		if (_inventory != null)
			return _inventory.getPurchase(sku);
		
		return null;
	}
	
	public SkuDetails getSKuDetails(String sku) {
		if (_inventory != null)
			return _inventory.getSkuDetails(sku);
		
		return null;
	}
	
	public static Billing getInstance() {
		if (_instance == null)
			_instance = new Billing();
		
		return _instance;
	}
	
	public void init(Activity act, String base64EncodedPublicKey) {
//		Log.d("test", "gwjgwj,Billing.init");
		dispose();
		
		_helper = new IabHelper(act, base64EncodedPublicKey);
		
		//_helper.enableDebugLogging(true);
		
		_helper.startSetup(new IabHelper.OnIabSetupFinishedListener() {
			public void onIabSetupFinished(IabResult result) {
//				Log.d("test", "gwjgwj,onIabSetupFinished," + result.isSuccess() + "," + result.getResponse() + "," + result.getMessage());
				if (!result.isSuccess()) {
//					CallLuaUtil.call(HandMachine.kPlayStoreInit, HandMachine.kCallFailed, new String[]{"flag"}, new Object[]{result.getMessage()});
				} else {
//					CallLuaUtil.call(HandMachine.kPlayStoreInit, HandMachine.kCallSuccess, new String[]{"flag"}, new Object[]{"ku-ku"});
				}
				
			}
		});
	}
	
	public void dispose() {
		if (_helper != null)
			_helper.dispose();
		_helper = null;
	}
	
	protected Billing() {
	}
}