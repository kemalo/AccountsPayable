import au.com.kabeus.ap.operations.APOnlineOperations;


public class TestCode {

	/**
	 * @param args
	 */
	public static void main(String[] args) {
		

		APOnlineOperations aponlineops= new APOnlineOperations();
	
		try {
			String Kemal = aponlineops.getCLOBData("AUP01", "0000008981", "00090908");
			System.out.println(Kemal);
		} catch (Exception e) {
			// TODO Auto-generated catch block
			e.printStackTrace();
		}

	}

}
